const express = require('express');
const validate = require('../middleware/validationMiddleware');
const { createLeadSchema } = require('../models/leadSchema');

const router = express.Router();

const createLead = (req, res) => {
  const newLead = {
    id: 'lead-' + Date.now(),
    ...req.body,
    createdAt: new Date().toISOString(),
  };
  (req.app.locals.leads || []).push(newLead);
  console.log('Lead created:', newLead);
  res.status(201).json({
    status: 'success',
    message: 'Lead created successfully',
    data: { lead: newLead },
  });
};

router.post('/', validate(createLeadSchema), createLead);

module.exports = router;
