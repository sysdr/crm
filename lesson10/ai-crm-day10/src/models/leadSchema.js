const Joi = require('joi');

const createLeadSchema = Joi.object({
  name: Joi.string().min(3).max(100).required()
    .messages({
      'string.empty': 'Lead name cannot be empty',
      'string.min': 'Lead name must be at least 3 characters long',
      'string.max': 'Lead name cannot exceed 100 characters',
      'any.required': 'Lead name is required',
    }),
  email: Joi.string().email().required()
    .messages({
      'string.empty': 'Email cannot be empty',
      'string.email': 'Email must be a valid email address',
      'any.required': 'Email is required',
    }),
  phone: Joi.string().pattern(/^\d{10,15}$/).optional() // 10-15 digits
    .messages({
      'string.pattern.base': 'Phone number must be between 10 and 15 digits',
    }),
  source: Joi.string().valid('Website', 'Referral', 'Advertisement', 'Other').required()
    .messages({
      'any.only': 'Lead source must be one of: Website, Referral, Advertisement, Other',
      'any.required': 'Lead source is required',
    }),
  notes: Joi.string().max(500).optional()
    .messages({
      'string.max': 'Notes cannot exceed 500 characters',
    }),
});

module.exports = {
  createLeadSchema,
};
