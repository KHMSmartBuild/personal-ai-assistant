import unittest
from security_privacy_agent import app

class SecurityPrivacyTestCase(unittest.TestCase):
    def setUp(self):
        self.app = app.test_client()
        self.app.testing = True

    def test_secure_data(self):
        response = self.app.post('/secure', json={"sensitive_data": "test"})
        self.assertEqual(response.status_code, 200)
        self.assertIn("Data secured", response.json["status"])
        self.assertTrue("encrypted_data" in response.json)

    def test_retrieve_data(self):
        response = self.app.post('/secure', json={"sensitive_data": "test"})
        encrypted_data = response.json["encrypted_data"]
        
        retrieve_response = self.app.post('/retrieve', json={"encrypted_data": encrypted_data})
        self.assertEqual(retrieve_response.status_code, 200)
        self.assertEqual(retrieve_response.json["decrypted_data"], "test")

if __name__ == '__main__':
    unittest.main()
