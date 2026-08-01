import unittest

from model import TextSentimentModel


class TextSentimentModelTest(unittest.TestCase):
    def setUp(self) -> None:
        self.model = TextSentimentModel()

    def test_positive_text_returns_positive_prediction(self) -> None:
        prediction = self.model.predict("The deployment is reliable and excellent.")

        self.assertEqual(prediction["label"], "positive")
        self.assertGreater(prediction["confidence"], 0.5)

    def test_negative_text_returns_negative_prediction(self) -> None:
        prediction = self.model.predict("The response is broken and unreliable.")

        self.assertEqual(prediction["label"], "negative")
        self.assertGreater(prediction["confidence"], 0.5)

    def test_neutral_text_has_even_confidence(self) -> None:
        prediction = self.model.predict("Railway serves this request.")

        self.assertEqual(prediction, {"label": "neutral", "confidence": 0.5})

    def test_batch_preserves_input_order(self) -> None:
        predictions = self.model.predict_batch(["excellent", "broken", "plain text"])

        self.assertEqual(
            [prediction["label"] for prediction in predictions],
            ["positive", "negative", "neutral"],
        )


if __name__ == "__main__":
    unittest.main()
