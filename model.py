from __future__ import annotations

import math
import re


class TextSentimentModel:
    """A tiny, deterministic linear model intended for deployment verification."""

    _weights = {
        "accurate": 1.1,
        "excellent": 1.5,
        "fast": 0.8,
        "good": 1.0,
        "reliable": 1.3,
        "broken": -1.5,
        "bad": -1.0,
        "failed": -1.2,
        "slow": -0.8,
        "unreliable": -1.3,
    }

    def predict(self, text: str) -> dict[str, str | float]:
        tokens = re.findall(r"[a-z]+", text.lower())
        score = sum(self._weights.get(token, 0.0) for token in tokens)
        if score == 0:
            return {"label": "neutral", "confidence": 0.5}

        probability = 1 / (1 + math.exp(-abs(score)))
        return {
            "label": "positive" if score > 0 else "negative",
            "confidence": round(probability, 6),
        }

    def predict_batch(self, texts: list[str]) -> list[dict[str, str | float]]:
        return [self.predict(text) for text in texts]
