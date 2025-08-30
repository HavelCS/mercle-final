const express = require('express');
const multer = require('multer');
const livenessService = require('../services/livenessService');
const faceService = require('../services/faceService');
const databaseService = require('../services/databaseService');

const router = express.Router();
const upload = multer({ storage: multer.memoryStorage() });

router.post('/liveness/create-session', async (req, res) => {
    try {
        const sessionId = await livenessService.createLivenessSession();
        res.json({ sessionId });
    } catch (error) {
        console.error('Create session error:', error);
        res.status(500).json({ error: error.message });
    }
});


router.post('/liveness/debug-results', async (req, res) => {
    try {
        const { sessionId } = req.body;
        
        if (!sessionId) {
            return res.status(400).json({ error: 'Session ID is required' });
        }
        
        const livenessResults = await livenessService.getLivenessResults(sessionId);
        
        // Return the full structure for debugging
        res.json({
            debug: true,
            livenessResults: livenessResults,
            hasReferenceImage: !!livenessResults.referenceImage,
            hasS3Object: !!livenessResults.s3Object,
            confidence: livenessResults.confidence
        });
    } catch (error) {
        console.error('Debug results error:', error);
        res.status(500).json({ error: error.message });
    }
});

// Get liveness results and process face registration
router.post('/liveness/process-results', async (req, res) => {
    try {
        const { sessionId } = req.body;
        
        if (!sessionId) {
            return res.status(400).json({ error: 'Session ID is required' });
        }
        
        // Get liveness results
        const livenessResults = await livenessService.getLivenessResults(sessionId);
        
        if (!livenessResults.isLive) {
            return res.json({
                success: false,
                message: 'Liveness check failed',
                confidence: livenessResults.confidence
            });
        }

        // Get reference image buffer
        let imageBuffer = null;
        
        if (livenessResults.referenceImage) {
            // Image is available as bytes
            imageBuffer = Buffer.from(livenessResults.referenceImage);
        } else if (livenessResults.s3Object) {
            // Image is stored in S3, download it
            console.log('Downloading image from S3...');
            imageBuffer = await livenessService.downloadImageFromS3(livenessResults.s3Object);
        } else {
            return res.status(400).json({
                error: 'No reference image available from liveness session'
            });
        }

        if (!imageBuffer || imageBuffer.length === 0) {
            return res.status(400).json({
                error: 'Invalid or empty reference image'
            });
        }

        // Check if face already exists
        const existingFace = await faceService.searchExistingFace(imageBuffer);
        
        if (existingFace.found) {
            // Update last seen for existing face
            await databaseService.updateLastSeen(existingFace.faceId);
            
            return res.json({
                success: true,
                isNewFace: false,
                uid: existingFace.faceId,
                confidence: existingFace.confidence,
                livenessScore: livenessResults.confidence
            });
        }

        // Register new face
        const registrationResult = await faceService.registerNewFace(imageBuffer);
        const uid = await databaseService.saveFaceRecord(registrationResult);

        res.json({
            success: true,
            isNewFace: true,
            uid: uid,
            livenessScore: livenessResults.confidence
        });

    } catch (error) {
        console.error('Liveness processing error:', error);
        res.status(500).json({ 
            error: error.message,
            details: 'Check server logs for more information'
        });
    }
});

// Manual face upload and processing (alternative endpoint)
router.post('/upload', upload.single('face'), async (req, res) => {
    try {
        if (!req.file) {
            return res.status(400).json({ error: 'No image uploaded' });
        }

        const imageBuffer = req.file.buffer;

        // Check if face already exists
        const existingFace = await faceService.searchExistingFace(imageBuffer);
        
        if (existingFace.found) {
            await databaseService.updateLastSeen(existingFace.faceId);
            
            return res.json({
                success: true,
                isNewFace: false,
                uid: existingFace.faceId,
                confidence: existingFace.confidence
            });
        }

        // Register new face
        const registrationResult = await faceService.registerNewFace(imageBuffer);
        const uid = await databaseService.saveFaceRecord(registrationResult);

        res.json({
            success: true,
            isNewFace: true,
            uid: uid
        });

    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

module.exports = router;