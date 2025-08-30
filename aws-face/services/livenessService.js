const { rekognition } = require('../config/aws-config');

class LivenessService {
    async createLivenessSession() {
        try {
            const params = {};
            
            // Only add S3 output config if bucket is specified
            if (process.env.S3_BUCKET_NAME) {
                params.Settings = {
                    OutputConfig: {
                        S3Bucket: process.env.S3_BUCKET_NAME
                    }
                };
            }

            const result = await rekognition.createFaceLivenessSession(params).promise();
            return result.SessionId;
        } catch (error) {
            throw new Error(`Failed to create liveness session: ${error.message}`);
        }
    }

    async getLivenessResults(sessionId) {
        try {
            const params = {
                SessionId: sessionId
            };

            const result = await rekognition.getFaceLivenessSessionResults(params).promise();
            
            console.log('Liveness Results:', JSON.stringify(result, null, 2));
            
            // Check if we have a reference image
            let referenceImageBuffer = null;
            if (result.ReferenceImage && result.ReferenceImage.Bytes) {
                referenceImageBuffer = result.ReferenceImage.Bytes;
            } else if (result.ReferenceImage && result.ReferenceImage.S3Object) {
                // If image is stored in S3, we'll need to fetch it
                console.log('Reference image stored in S3:', result.ReferenceImage.S3Object);
            }
            
            return {
                isLive: result.Confidence > 80,
                confidence: result.Confidence,
                referenceImage: referenceImageBuffer,
                s3Object: result.ReferenceImage ? result.ReferenceImage.S3Object : null,
                auditImages: result.AuditImages
            };
        } catch (error) {
            throw new Error(`Failed to get liveness results: ${error.message}`);
        }
    }

    async downloadImageFromS3(s3Object) {
        try {
            const { s3 } = require('../config/aws-config');
            const params = {
                Bucket: s3Object.Bucket,
                Key: s3Object.Name
            };
            
            const result = await s3.getObject(params).promise();
            return result.Body;
        } catch (error) {
            throw new Error(`Failed to download image from S3: ${error.message}`);
        }
    }
}

module.exports = new LivenessService();