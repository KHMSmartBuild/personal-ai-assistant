import unittest
from proactive_assistance_agent import app

class ProactiveAssistanceTestCase(unittest.TestCase):
    def setUp(self):
        self.app = app.test_client()
        self.app.testing = True

    def test_assist_user(self):
        response = self.app.post('/assist', json={"context": "User is feeling stressed"})
        self.assertEqual(response.status_code, 200)
        self.assertIn("suggestion", response.json)
        self.assertEqual(response.json["context"], "User is feeling stressed")

if __name__ == '__main__':
    unittest.main()
