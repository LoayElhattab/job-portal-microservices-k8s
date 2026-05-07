const express = require('express');
const auth = require('../middleware/auth');
const { createJob, getJobs, getJobById, updateJob, deleteJob } = require('../controllers/jobs.controller');

const router = express.Router();

router.post('/',        auth, createJob);
router.get('/',              getJobs);
router.get('/:id',           getJobById);
router.patch('/:id',   auth, updateJob);
router.delete('/:id',  auth, deleteJob);

module.exports = router;
