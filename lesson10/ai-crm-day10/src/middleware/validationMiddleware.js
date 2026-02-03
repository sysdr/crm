const AppError = require('../utils/AppError');

const validate = (schema) => (req, res, next) => {
  const { error } = schema.validate(req.body, { abortEarly: false });

  if (error) {
    const details = error.details.map(err => ({
      field: err.context.key,
      value: err.context.value,
      reason: err.message,
    }));
    return next(new AppError('Invalid input data provided.', 400, 'VALIDATION_ERROR', details));
  }
  next();
};

module.exports = validate;
