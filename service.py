from __future__ import annotations

import bentoml

from model import TextSentimentModel


@bentoml.service(
    name="railway_sentiment",
    workers=1,
    traffic={"timeout": 10, "concurrency": 32},
)
class SentimentService:
    def __init__(self) -> None:
        self.model = TextSentimentModel()

    @bentoml.api
    def classify(self, text: str) -> dict[str, str | float]:
        return self.model.predict(text)

    @bentoml.api
    def classify_batch(self, texts: list[str]) -> list[dict[str, str | float]]:
        return self.model.predict_batch(texts)
