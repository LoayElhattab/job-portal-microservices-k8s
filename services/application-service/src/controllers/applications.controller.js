const applicationsService = require('../services/applications.service');
const { ApiResponse } = require('../utils/ApiResponse');
const { ApiError } = require('../utils/ApiError');

const applyForJob = async (req, res, next) => {
  try {
    const { jobId, employerId, coverLetter } = req.body;
    
    if (!jobId) {
      throw new ApiError(400, 'BAD_REQUEST', 'jobId is required');
    }

    const seekerId = req.user.userId;
    
    const newApplication = await applicationsService.applyForJob(jobId, seekerId, employerId, coverLetter);
    
    res.status(201).json(new ApiResponse(newApplication));
  } catch (error) {
    next(error);
  }
};

const getApplications = async (req, res, next) => {
  try {
    const { userId, role } = req.user;
    
    const applications = await applicationsService.getApplications(userId, role);
    
    res.status(200).json(new ApiResponse(applications));
  } catch (error) {
    next(error);
  }
};

const updateApplicationStatus = async (req, res, next) => {
  try {
    const applicationId = req.params.id;
    const { status } = req.body;
    const employerId = req.user.userId;
    
    const updatedApp = await applicationsService.updateApplicationStatus(applicationId, employerId, status);
    
    res.status(200).json(new ApiResponse(updatedApp));
  } catch (error) {
    next(error);
  }
};

module.exports = {
  applyForJob,
  getApplications,
  updateApplicationStatus
};
