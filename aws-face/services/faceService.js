const { rekognition, s3 } = require('../config/aws-config');
const { v4: uuidv4 } = require('uuid');

class FaceService {
    async searchExistingFace(imageBuffer) {
        try {
            const params = {
                CollectionId: 'face-registry-collection',
                Image: {
                    Bytes: imageBuffer
                },
                MaxFaces: 1,
                FaceMatchThreshold: 95
            };
    
            const result = await rekognition.searchFacesByImage(params).promise();
            
            if (result.FaceMatches && result.FaceMatches.length > 0) {
                const rekognitionFaceId = result.FaceMatches[0].Face.FaceId;
                
                // Look up the face_id using rekognition_face_id
                const { dynamodb } = require('../config/aws-config');
                const dbResult = await dynamodb.scan({
                    TableName: 'FaceRegistry',
                    FilterExpression: 'rekognition_face_id = :rid',
                    ExpressionAttributeValues: {
                        ':rid': rekognitionFaceId
                    }
                }).promise();
                
                if (dbResult.Items && dbResult.Items.length > 0) {
                    return {
                        found: true,
                        faceId: dbResult.Items[0].face_id,  // Return face_id, not rekognition_face_id
                        confidence: result.FaceMatches[0].Similarity
                    };
                }
            }
    
            return { found: false };
        } catch (error) {
            if (error.code === 'InvalidParameterException') {
                return { found: false };
            }
            throw new Error(`Face search failed: ${error.message}`);
        }
    }

    async registerNewFace(imageBuffer, userId = null) {
        try {
            const faceId = uuidv4();
            const timestamp = new Date().toISOString();

            // Store image in S3
            const s3Key = `faces/${faceId}.jpg`;
            await s3.putObject({
                Bucket: process.env.S3_BUCKET_NAME,
                Key: s3Key,
                Body: imageBuffer,
                ContentType: 'image/jpeg'
            }).promise();

            // Index face in Rekognition
            const indexParams = {
                CollectionId: 'face-registry-collection',
                Image: {
                    Bytes: imageBuffer
                },
                ExternalImageId: faceId,
                DetectionAttributes: ['ALL']
            };

            const indexResult = await rekognition.indexFaces(indexParams).promise();
            
            if (indexResult.FaceRecords && indexResult.FaceRecords.length > 0) {
                const rekognitionFaceId = indexResult.FaceRecords[0].Face.FaceId;
                
                return {
                    success: true,
                    faceId: faceId,
                    rekognitionFaceId: rekognitionFaceId,
                    s3Key: s3Key,
                    timestamp: timestamp
                };
            }

            throw new Error('No face detected in the image');
        } catch (error) {
            throw new Error(`Face registration failed: ${error.message}`);
        }
    }
}

module.exports = new FaceService();