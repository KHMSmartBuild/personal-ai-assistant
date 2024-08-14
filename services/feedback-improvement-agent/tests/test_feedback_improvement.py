import unittest
from feedback_improvement_agent import app

class FeedbackImprovementTestCase(unittest.TestCase):
    def setUp(self):
        self.app = app.test_client()
        self.app.testing = True

    def test_collect_feedback(self):
        response = self.app.post('/feedback', json={"feedback": "Great job!"})
        self.assertEqual(response.status_code, 200)
        self.assertIn("Feedback received", response.json["status"])
        self.assertEqual(response.json["feedback"], "Great job!")

    def test_get_feedbacks(self):
        self.app.post('/feedback', json={"feedback": "Great job!"})
        response = self.app.get('/feedbacks')
        self.assertEqual(response.status_code, 200)
        self.assertIn("Great job!", response.json["feedbacks"])

if __name__ == '__main__':
    unittest.main()
