
import type { ApiErrorDetails } from './httpTypes';

export class ApiError extends Error {
  readonly status?: number;
  readonly code: string;

  constructor(details: ApiErrorDetails) {
    super(details.message);

    this.name = 'ApiError';
    this.status = details.status;
    this.code = details.code;

    Object.setPrototypeOf(this, new.target.prototype);
  }
}
