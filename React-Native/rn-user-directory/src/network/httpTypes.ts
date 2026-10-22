export type HttpMethod =
  | 'GET'
  | 'POST'
  | 'PUT'
  | 'PATCH'
  | 'DELETE';

export type QueryParams = Record<
  string,
  string | number | boolean | undefined
>;

export interface RequestOptions<TBody = unknown> {
  method: HttpMethod;
  path: string;
  params?: QueryParams;
  body?: TBody;
  headers?: Record<string, string>;
  signal?: AbortSignal;
}

export interface ApiErrorDetails {
  status?: number;
  code: string;
  message: string;
}