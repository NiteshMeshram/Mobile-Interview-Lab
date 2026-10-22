import { QueryParams, RequestOptions } from "./httpTypes";

export interface HttpClient {
  request<TResponse, TBody = unknown>(
    options: RequestOptions<TBody>
  ): Promise<TResponse>;

  get<TResponse>(
    path: string,
    params?: QueryParams
  ): Promise<TResponse>;

  post<TResponse, TBody>(
    path: string,
    body: TBody,
    params?: QueryParams
  ): Promise<TResponse>;

  put<TResponse, TBody>(
    path: string,
    body: TBody,
    params?: QueryParams
  ): Promise<TResponse>;

  patch<TResponse, TBody>(
    path: string,
    body: TBody,
    params?: QueryParams
  ): Promise<TResponse>;

  delete<TResponse = void>(
    path: string,
    params?: QueryParams
  ): Promise<TResponse>;
}