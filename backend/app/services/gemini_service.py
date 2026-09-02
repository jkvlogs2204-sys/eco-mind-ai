import os
import json
import logging
import re
from typing import Dict, Any, Optional, List

logger = logging.getLogger("gemini_service")

# Try to import the real Gemini SDK
try:
    from google import genai
    from google.genai import types
    _GEMINI_AVAILABLE = True
except ImportError:
    _GEMINI_AVAILABLE = False
    logger.warning("google-genai not installed. Using deterministic fallback engine.")


def _get_gemini_client():
    """Returns a Gemini client if API key is available, else None."""
    if not _GEMINI_AVAILABLE:
        return None
    api_key = os.getenv("GEMINI_API_KEY", "")
    if not api_key:
        return None
    try:
        return genai.Client(api_key=api_key)
    except Exception as e:
        logger.warning(f"Failed to create Gemini client: {e}")
        return None


class GeminiService:
    """
    EcoMind AI — Gemini Sustainability Intelligence Service.
    - Product sustainability insights (cached)
    - AI-powered natural language product search
    """

    _cache: Dict[str, Dict[str, Any]] = {}

    SYSTEM_INSTRUCTION = """
You are EcoMind AI's Sustainability Intelligence Assistant. Explain environmental information concisely and responsibly.
The official Eco Score, grade and decision are calculated by EcoMind AI's deterministic scoring engine. DO NOT change them.

Respond with ONLY valid JSON matching this schema:
{
  "summary": "1 sentence overview",
  "why_this_score": "1 sentence explanation of score",
  "impact_drivers": ["Factor 1", "Factor 2"],
  "positive_factors": ["Positive 1"],
  "actions": {
    "use_better": "Usage advice",
    "reuse": "Reuse tip",
    "repair": "Repair tip",
    "reduce": "Reduction tip",
    "recycle": "Recycling tip",
    "replace": null
  },
  "better_alternative": null,
  "disposal_guidance": "1 sentence disposal tip",
  "confidence_note": "Data status note"
}
"""

    # ── AI Product Search ─────────────────────────────────────────────────────

    SEARCH_SYSTEM_PROMPT = """
You are EcoMind AI's product search assistant. Extract structured search filters from natural language queries.

The product database has these fields:
- product_name (text)
- brand (text)
- category (text, e.g. Beverages, Electronics, Clothing, Food, Household)
- material (text, e.g. Plastic, Glass, Steel, Cotton, Cardboard)
- packaging (text)
- carbon_footprint (float, kg CO2e — lower is better)
- water_footprint (float, litres — lower is better)
- recyclability (float, 0-100 — higher is better)
- reuse_potential (float, 0-100 — higher is better)
- lifespan (int, days)

Return ONLY valid JSON with this exact schema (use null for unspecified filters):
{
  "keyword": "general keyword to search in name/brand/category/material",
  "brand": null,
  "category": null,
  "material": null,
  "max_carbon": null,
  "max_water": null,
  "min_recyclability": null,
  "min_reuse": null,
  "min_eco_score": null,
  "max_eco_score": null,
  "sort_by": "eco_score",
  "sort_order": "desc",
  "explanation": "1 sentence: what the user is looking for"
}

Sort options: eco_score, carbon_footprint, water_footprint, recyclability, product_name
Sort order: asc or desc

Examples:
- "low carbon drinks" → category="Beverages", max_carbon=1.0, sort_by="carbon_footprint", sort_order="asc"
- "most eco friendly products" → sort_by="eco_score", sort_order="desc", min_eco_score=70
- "glass products high recyclability" → material="Glass", min_recyclability=80
- "Nike" → brand="Nike"
- "plastic under 2kg carbon" → material="Plastic", max_carbon=2.0
"""

    @classmethod
    def ai_parse_search_query(cls, query: str) -> Dict[str, Any]:
        """
        Uses Gemini API to parse a natural language search query into structured filters.
        Falls back to simple keyword matching if Gemini is unavailable.
        """
        if not query or not query.strip():
            return cls._empty_search_filters()

        # Try Gemini API
        client = _get_gemini_client()
        if client:
            try:
                response = client.models.generate_content(
                    model="gemini-2.0-flash",
                    contents=f"Search query: {query}",
                    config=types.GenerateContentConfig(
                        system_instruction=cls.SEARCH_SYSTEM_PROMPT,
                        temperature=0.1,
                        max_output_tokens=512,
                    )
                )
                raw = response.text.strip()
                # Strip markdown code fences if present
                raw = re.sub(r'^```(?:json)?\s*', '', raw, flags=re.MULTILINE)
                raw = re.sub(r'```\s*$', '', raw, flags=re.MULTILINE)
                parsed = json.loads(raw.strip())
                parsed["explanation"] = parsed.get("explanation", f'Searching for: {query}')
                parsed["ai_powered"] = True
                return parsed
            except Exception as e:
                logger.warning(f"Gemini search parse failed: {e}. Using keyword fallback.")

        # Fallback: simple keyword-based filter extraction
        return cls._fallback_parse_search_query(query)

    @classmethod
    def _fallback_parse_search_query(cls, query: str) -> Dict[str, Any]:
        """Simple rule-based query parser when Gemini is unavailable."""
        q = query.lower().strip()
        filters = cls._empty_search_filters()
        filters["ai_powered"] = False

        # Sort / quality hints
        clean_words = []
        words = q.split()

        if any(w in q for w in ["eco", "green", "sustainable", "best", "top", "high score"]):
            filters["sort_by"] = "eco_score"
            filters["sort_order"] = "desc"
        if "low carbon" in q or "less carbon" in q or "carbon" in q:
            filters["sort_by"] = "carbon_footprint"
            filters["sort_order"] = "asc"
        if "low water" in q or "less water" in q or "water" in q:
            filters["sort_by"] = "water_footprint"
            filters["sort_order"] = "asc"
        if "recyclable" in q or "recycle" in q:
            filters["min_recyclability"] = 70.0
            filters["sort_by"] = "recyclability"
            filters["sort_order"] = "desc"

        # Category hints matching actual DB categories:
        # 'Beverage Containers', 'Accessories', 'Utensils', 'Personal Care', 'Electronics', 'Bags & Carriers', 'Food Packaging', 'Kitchenware'
        category_hints = {
            "beverage": "Beverage", "drink": "Beverage", "bottle": "Beverage",
            "personal": "Personal Care", "care": "Personal Care", "hygiene": "Personal Care",
            "electronic": "Electronics", "phone": "Electronics", "laptop": "Electronics",
            "bag": "Bags", "carrier": "Bags",
            "utensil": "Utensils", "fork": "Utensils", "spoon": "Utensils",
            "food": "Food", "packaging": "Packaging",
            "kitchen": "Kitchenware",
            "accessory": "Accessories", "accessories": "Accessories"
        }
        for hint, cat in category_hints.items():
            if hint in q:
                filters["category"] = cat
                break

        # Material hints
        material_hints = {
            "plastic": "Plastic", "glass": "Glass", "steel": "Steel", "stainless": "Steel",
            "alumin": "Aluminium", "paper": "Paper", "cardboard": "Cardboard",
            "cotton": "Cotton", "bamboo": "Bamboo", "denim": "Denim"
        }
        for hint, mat in material_hints.items():
            if hint in q:
                filters["material"] = mat
                break

        # Filter out modifier words to get a clean search keyword
        skip_words = {"low", "high", "less", "top", "best", "eco", "green", "carbon", "water", "score", "recyclable", "recycle", "sustainable"}
        filtered_terms = [w for w in words if w not in skip_words]
        if filtered_terms:
            filters["keyword"] = " ".join(filtered_terms)
        else:
            filters["keyword"] = None

        filters["explanation"] = f'Smart Search: category="{filters.get("category") or "Any"}", material="{filters.get("material") or "Any"}", sorted by {filters.get("sort_by")}'
        return filters

    @classmethod
    def _empty_search_filters(cls) -> Dict[str, Any]:
        return {
            "keyword": None,
            "brand": None,
            "category": None,
            "material": None,
            "max_carbon": None,
            "max_water": None,
            "min_recyclability": None,
            "min_reuse": None,
            "min_eco_score": None,
            "max_eco_score": None,
            "sort_by": "eco_score",
            "sort_order": "desc",
            "explanation": "Show all products",
            "ai_powered": False,
        }

    # ── Sustainability Insight (existing) ─────────────────────────────────────

    @classmethod
    def generate_sustainability_insight(
        cls,
        product_id: int,
        product_name: str,
        brand: str,
        category: str,
        material: str,
        packaging: str,
        carbon_footprint: float,
        water_footprint: float,
        recyclability: float,
        reuse_potential: float,
        lifespan: int,
        eco_score: float,
        eco_grade: str,
        decision: str,
        data_status: str,
        components: Dict[str, float],
        better_alt_name: Optional[str] = None
    ) -> Dict[str, Any]:
        cache_key = f"{product_id}_{eco_score}_{data_status}"
        if cache_key in cls._cache:
            return cls._cache[cache_key]

        insight = cls._generate_fallback_insight(
            product_name, category, material, packaging,
            carbon_footprint, water_footprint, recyclability, reuse_potential,
            eco_score, eco_grade, decision, data_status, components, better_alt_name
        )
        cls._cache[cache_key] = insight
        return insight

    @classmethod
    def prewarm_cache(cls, product_id: int, eco_score: float, data_status: str, insight: Dict[str, Any]):
        cache_key = f"{product_id}_{eco_score}_{data_status}"
        cls._cache[cache_key] = insight

    @classmethod
    def _validate_and_format(cls, data: Dict[str, Any], data_status: str, source: str) -> Dict[str, Any]:
        return {
            "summary": data.get("summary", "Product environmental assessment analysis."),
            "why_this_score": data.get("why_this_score", "Calculated using transparent weighted lifecycle scoring."),
            "impact_drivers": data.get("impact_drivers", []),
            "positive_factors": data.get("positive_factors", []),
            "actions": {
                "use_better": data.get("actions", {}).get("use_better", "Use mindfully to maximize product lifespan."),
                "reuse": data.get("actions", {}).get("reuse", "Reuse as many times as possible."),
                "repair": data.get("actions", {}).get("repair", "Repair components if damaged."),
                "reduce": data.get("actions", {}).get("reduce", "Reduce single-use purchases."),
                "recycle": data.get("actions", {}).get("recycle", "Recycle according to material guidelines."),
                "replace": data.get("actions", {}).get("replace", None)
            },
            "better_alternative": data.get("better_alternative", None),
            "disposal_guidance": data.get("disposal_guidance", "Dispose responsibly in designated recycling streams."),
            "confidence_note": data.get("confidence_note", f"Environmental metrics status: {data_status}."),
            "source": source
        }

    @classmethod
    def _generate_fallback_insight(
        cls,
        product_name: str,
        category: str,
        material: str,
        packaging: str,
        carbon_footprint: float,
        water_footprint: float,
        recyclability: float,
        reuse_potential: float,
        eco_score: float,
        eco_grade: str,
        decision: str,
        data_status: str,
        components: Dict[str, float],
        better_alt_name: Optional[str]
    ) -> Dict[str, Any]:
        strongest = max(components.items(), key=lambda x: x[1])
        weakest = min(components.items(), key=lambda x: x[1])

        impact_drivers = []
        if components.get("carbon", 100) < 70:
            impact_drivers.append(f"Carbon intensity ({carbon_footprint} kg CO2e) reduces sub-score.")
        if components.get("packaging", 100) < 70:
            impact_drivers.append(f"Packaging material ({packaging}) increases disposal impact.")
        if not impact_drivers:
            impact_drivers.append(f"Lowest sub-score factor is {weakest[0]} ({weakest[1]:.1f}/100).")

        positives = []
        if recyclability >= 80:
            positives.append(f"High recyclability rate of {recyclability}%.")
        if reuse_potential >= 80:
            positives.append(f"Strong reuse potential ({reuse_potential}%), extending active lifespan.")
        if not positives:
            positives.append(f"Strongest sub-score factor is {strongest[0]} ({strongest[1]:.1f}/100).")

        return {
            "summary": f"{product_name} achieves Grade {eco_grade} ({eco_score}/100) with classification {decision}.",
            "why_this_score": f"Score calculated from Carbon (30%), Water (20%), Packaging (15%), Recyclability (20%), and Reuse (15%). Strongest factor: {strongest[0]} ({strongest[1]:.1f}/100).",
            "impact_drivers": impact_drivers,
            "positive_factors": positives,
            "actions": {
                "use_better": "Maximize product utility and avoid single-use consumption patterns.",
                "reuse": f"Reuse this {category.lower()} product to amortize manufacturing footprint.",
                "repair": "Maintain and repair seals, lids, or components to delay disposal.",
                "reduce": "Choose durable reusable items over single-use alternatives.",
                "recycle": f"Ensure {packaging} packaging is placed in designated municipal recycling streams.",
                "replace": f"Consider switching to {better_alt_name}" if better_alt_name else None
            },
            "better_alternative": better_alt_name,
            "disposal_guidance": f"Separate {packaging} packaging and recycle {material} according to local waste guidelines.",
            "confidence_note": f"Verified Real-Time Engine. Data status: {data_status}.",
            "source": "EcoMind High-Speed Engine"
        }
