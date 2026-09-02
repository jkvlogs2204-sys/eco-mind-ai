from typing import Dict, Any, Optional

class EcoEngine:
    """
    Transparent, explainable Eco Score Engine.
    Weightings:
      - Carbon Impact       -> 30%
      - Water Impact        -> 20%
      - Packaging           -> 15%
      - Recyclability       -> 20%
      - Reuse / Lifespan    -> 15%
    """

    PACKAGING_SCORES = {
        "glass": 90.0,
        "aluminum": 85.0,
        "metal": 85.0,
        "paper": 80.0,
        "cardboard": 80.0,
        "biodegradable": 95.0,
        "bamboo": 95.0,
        "reusable plastic": 60.0,
        "pet plastic": 50.0,
        "plastic": 40.0,
        "single-use plastic": 20.0,
        "styrofoam": 10.0,
        "composite": 30.0
    }

    @classmethod
    def calculate_carbon_score(cls, carbon_footprint: float) -> float:
        """
        Converts carbon footprint (kg CO2e) into a 0-100 sub-score.
        0.0 kg -> 100. Higher values reduce score smoothly.
        """
        score = 100.0 - (carbon_footprint * 30.0)
        return max(0.0, min(100.0, round(score, 1)))

    @classmethod
    def calculate_water_score(cls, water_footprint: float) -> float:
        """
        Converts water footprint (litres) into a 0-100 sub-score.
        0.0 L -> 100. Higher values reduce score smoothly.
        """
        score = 100.0 - (water_footprint * 10.0)
        return max(0.0, min(100.0, round(score, 1)))

    @classmethod
    def calculate_packaging_score(cls, packaging: str) -> float:
        """
        Evaluates packaging material on a 0-100 scale.
        """
        pkg_clean = packaging.strip().lower()
        for key, value in cls.PACKAGING_SCORES.items():
            if key in pkg_clean:
                return value
        return 50.0

    @classmethod
    def calculate_grade(cls, score: float) -> tuple[str, str]:
        """
        Maps score (0-100) to Grade and Decision State.
        Decision mapping:
          - 80-100 -> GREEN (EXCELLENT CHOICE / GOOD CHOICE)
          - 60-79  -> YELLOW (MODERATE IMPACT)
          - 0-59   -> RED (HIGH IMPACT / VERY HIGH IMPACT)
        """
        score = max(0.0, min(100.0, score))
        if score >= 90.0:
            return "A+", "EXCELLENT CHOICE"
        elif score >= 80.0:
            return "A", "GOOD CHOICE"
        elif score >= 70.0:
            return "B", "MODERATE IMPACT"
        elif score >= 60.0:
            return "C", "MODERATE IMPACT"
        elif score >= 50.0:
            return "D", "HIGH IMPACT"
        else:
            return "E", "VERY HIGH IMPACT"

    @classmethod
    def generate_explanation(cls, grade: str, components: Dict[str, float], packaging: str) -> str:
        """
        Generates a transparent natural language breakdown explanation.
        """
        strongest = max(components.items(), key=lambda x: x[1])
        weakest = min(components.items(), key=lambda x: x[1])

        explanations = []
        if grade in ["A+", "A"]:
            explanations.append("This product has an outstanding Eco Score with high sustainability performance across key metrics.")
        elif grade == "B":
            explanations.append("This product is a good choice with manageable environmental impact.")
        elif grade == "C":
            explanations.append("This product presents moderate environmental impact.")
        elif grade == "D":
            explanations.append("This product has a high environmental footprint and should be used with caution.")
        else:
            explanations.append("This product has a very high environmental impact. Consider switching to a sustainable alternative.")

        explanations.append(f"Its strongest factor is {strongest[0]} (score: {strongest[1]}/100), while {weakest[0]} needs improvement (score: {weakest[1]}/100).")
        return " ".join(explanations)

    @classmethod
    def evaluate(
        cls,
        carbon_footprint: float,
        water_footprint: float,
        packaging: str,
        recyclability: float,
        reuse_potential: float
    ) -> Dict[str, Any]:
        """
        Executes full transparent scoring pipeline.
        """
        carbon_s = cls.calculate_carbon_score(carbon_footprint)
        water_s = cls.calculate_water_score(water_footprint)
        pkg_s = cls.calculate_packaging_score(packaging)
        recyc_s = max(0.0, min(100.0, recyclability))
        reuse_s = max(0.0, min(100.0, reuse_potential))

        total_score = (
            (carbon_s * 0.30) +
            (water_s * 0.20) +
            (pkg_s * 0.15) +
            (recyc_s * 0.20) +
            (reuse_s * 0.15)
        )
        total_score = round(max(0.0, min(100.0, total_score)), 1)

        grade, decision = cls.calculate_grade(total_score)

        components = {
            "carbon": carbon_s,
            "water": water_s,
            "packaging": pkg_s,
            "recyclability": recyc_s,
            "reuse": reuse_s
        }

        explanation = cls.generate_explanation(grade, components, packaging)

        return {
            "eco_score": total_score,
            "grade": grade,
            "decision": decision,
            "explanation": explanation,
            "components": components
        }

    @classmethod
    def find_better_alternative(cls, db: Any, current_product: Any, current_score: float) -> Optional[Dict[str, Any]]:
        """
        Finds a higher-scoring product in the same or related category.
        """
        from app.models import Product

        candidates = db.query(Product).filter(
            Product.id != current_product.id,
            Product.category == current_product.category
        ).all()

        best = None
        best_score = current_score

        for p in candidates:
            score_data = cls.evaluate(
                carbon_footprint=p.carbon_footprint,
                water_footprint=p.water_footprint,
                packaging=p.packaging,
                recyclability=p.recyclability,
                reuse_potential=p.reuse_potential
            )
            if score_data["eco_score"] > best_score + 5.0: # Must be noticeably better (+5 score)
                best_score = score_data["eco_score"]
                best = {
                    "id": p.id,
                    "product_name": p.product_name,
                    "brand": p.brand,
                    "category": p.category,
                    "eco_score": score_data["eco_score"],
                    "eco_grade": score_data["grade"],
                    "reason": f"Higher reuse potential ({p.reuse_potential}%) and lower carbon intensity ({p.carbon_footprint} kg CO2e)."
                }

        return best
