import random
import json

vector = [round(random.uniform(-1, 1), 6) for _ in range(512)]  # 512 floats in range [-1,1]

request = {
    "queries": [
        {
            "id": "test_face_1",
            "vector": vector
        }
    ]
}

print(json.dumps(request, indent=2))