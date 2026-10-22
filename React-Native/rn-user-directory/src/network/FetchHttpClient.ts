
import type { HttpClient } from './HttpClient';
import type {
  QueryParams,
  RequestOptions,
} from './httpTypes';
import { ApiError } from './ApiError';
import { apiConfig } from '../config/apiConfig';

export class FetchHttpClient implements HttpClient {
  async request<TResponse, TBody = unknown>(
    options: RequestOptions<TBody>
  ): Promise<TResponse> {
    const baseUrl = `${apiConfig.baseUrl.replace(/\/+$/, '')}/`;
    const path = options.path.replace(/^\/+/, '');
    const url = new URL(path, baseUrl);

    Object.entries(options.params ?? {}).forEach(
      ([key, value]) => {
        if (value !== undefined) {
          url.searchParams.set(key, String(value));
        }
      }
    );

    const controller = new AbortController();
    let timedOut = false;

    const timeoutId = setTimeout(() => {
      timedOut = true;
      controller.abort();
    }, apiConfig.timeoutMs);

    const signal = options.signal
      ? AbortSignal.any([
          options.signal,
          controller.signal,
        ])
      : controller.signal;

    try {
      const response = await fetch(url.toString(), {
        method: options.method,
        headers: {
          Accept: 'application/json',
          ...(options.body !== undefined
            ? { 'Content-Type': 'application/json' }
            : {}),
          ...options.headers,
        },
        ...(options.body !== undefined
          ? { body: JSON.stringify(options.body) }
          : {}),
        signal,
      });

      if (!response.ok) {
        const errorBody = await response.text();

        throw new ApiError({
          status: response.status,
          code: 'HTTP_ERROR',
          message: `HTTP ${response.status}: ${
            errorBody || response.statusText
          }`,
        });
      }

      if (
        response.status === 204 ||
        options.method === 'DELETE'
      ) {
        return undefined as TResponse;
      }

      const responseText = await response.text();

      if (!responseText) {
        return undefined as TResponse;
      }

      try {
        return JSON.parse(responseText) as TResponse;
      } catch {
        throw new ApiError({
          status: response.status,
          code: 'INVALID_RESPONSE',
          message: 'The server returned invalid JSON.',
        });
      }
    } catch (error: unknown) {
      if (error instanceof ApiError) {
        throw error;
      }

      if (timedOut) {
        throw new ApiError({
          code: 'REQUEST_TIMEOUT',
          message: `The request timed out after ${apiConfig.timeoutMs} ms.`,
        });
      }

      if (options.signal?.aborted) {
        throw new ApiError({
          code: 'REQUEST_ABORTED',
          message: 'The request was cancelled.',
        });
      }

      throw new ApiError({
        code: 'NETWORK_ERROR',
        message:
          error instanceof Error
            ? error.message
            : 'An unexpected network error occurred.',
      });
    } finally {
      clearTimeout(timeoutId);
    }
  }

  get<TResponse>(
    path: string,
    params?: QueryParams
  ): Promise<TResponse> {
    return this.request<TResponse>({
      method: 'GET',
      path,
      params,
    });
  }

  post<TResponse, TBody>(
    path: string,
    body: TBody,
    params?: QueryParams
  ): Promise<TResponse> {
    return this.request<TResponse, TBody>({
      method: 'POST',
      path,
      body,
      params,
    });
  }

  put<TResponse, TBody>(
    path: string,
    body: TBody,
    params?: QueryParams
  ): Promise<TResponse> {
    return this.request<TResponse, TBody>({
      method: 'PUT',
      path,
      body,
      params,
    });
  }

  patch<TResponse, TBody>(
    path: string,
    body: TBody,
    params?: QueryParams
  ): Promise<TResponse> {
    return this.request<TResponse, TBody>({
      method: 'PATCH',
      path,
      body,
      params,
    });
  }

  delete<TResponse = void>(
    path: string,
    params?: QueryParams
  ): Promise<TResponse> {
    return this.request<TResponse>({
      method: 'DELETE',
      path,
      params,
    });
  }
}
