const JobsService = require('../services/jobs.service');
const ApiResponse = require('../utils/ApiResponse');
const ApiError = require('../utils/ApiError');

async function createJob(req, res, next) {
  try {
    if (req.user.role !== 'employer') {
      return res.status(403).json(ApiError.forbidden());
    }

    const { title, company, location, description, salary } = req.body;
    if (!title || !company || !location || !description) {
      return res.status(400).json(ApiError.validationError('title, company, location and description are required'));
    }

    const data = await JobsService.createJob({
      employerId: req.user.userId,
      title, company, location, description, salary,
    });
    res.status(201).json(ApiResponse.success(data));
  } catch (err) {
    next(err);
  }
}

async function getJobs(req, res, next) {
  try {
    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 20;
    const { search, location } = req.query;

    const data = await JobsService.getJobs({ search, location, page, limit });
    res.status(200).json(ApiResponse.success(data.jobs, data.meta));
  } catch (err) {
    next(err);
  }
}

async function getJobById(req, res, next) {
  try {
    const data = await JobsService.getJobById(req.params.id);
    res.status(200).json(ApiResponse.success(data));
  } catch (err) {
    next(err);
  }
}

async function updateJob(req, res, next) {
  try {
    if (req.user.role !== 'employer') {
      return res.status(403).json(ApiError.forbidden());
    }

    const data = await JobsService.updateJob({
      id: req.params.id,
      employerId: req.user.userId,
      fields: req.body,
    });
    res.status(200).json(ApiResponse.success(data));
  } catch (err) {
    next(err);
  }
}

async function deleteJob(req, res, next) {
  try {
    if (req.user.role !== 'employer') {
      return res.status(403).json(ApiError.forbidden());
    }

    const data = await JobsService.deleteJob({
      id: req.params.id,
      employerId: req.user.userId,
    });
    res.status(200).json(ApiResponse.success(data));
  } catch (err) {
    next(err);
  }
}

module.exports = { createJob, getJobs, getJobById, updateJob, deleteJob };
