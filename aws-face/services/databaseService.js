const { dynamodb } = require('../config/aws-config');

class DatabaseService {
    async saveFaceRecord(faceData) {
        try {
            const params = {
                TableName: 'FaceRegistry',
                Item: {
                    face_id: faceData.faceId,
                    rekognition_face_id: faceData.rekognitionFaceId,
                    s3_key: faceData.s3Key,
                    created_at: faceData.timestamp,
                    last_seen: faceData.timestamp,
                    access_count: 1
                }
            };

            await dynamodb.put(params).promise();
            return faceData.faceId;
        } catch (error) {
            throw new Error(`Database save failed: ${error.message}`);
        }
    }

    async getFaceRecord(faceId) {
        try {
            const params = {
                TableName: 'FaceRegistry',
                Key: {
                    face_id: faceId
                }
            };

            const result = await dynamodb.get(params).promise();
            return result.Item;
        } catch (error) {
            throw new Error(`Database get failed: ${error.message}`);
        }
    }

    async updateLastSeen(faceId) {
        try {
            const params = {
                TableName: 'FaceRegistry',
                Key: {
                    face_id: faceId
                },
                UpdateExpression: 'SET last_seen = :timestamp, access_count = if_not_exists(access_count, :zero) + :inc',
                ExpressionAttributeValues: {
                    ':timestamp': new Date().toISOString(),
                    ':inc': 1,
                    ':zero': 0
                }
            };
    
            await dynamodb.update(params).promise();
        } catch (error) {
            throw new Error(`Database update failed: ${error.message}`);
        }
    }
}

module.exports = new DatabaseService();