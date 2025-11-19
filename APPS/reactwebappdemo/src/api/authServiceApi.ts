import apiClient from './apiBase';

/**
 * Login request model
 */
export interface LoginRequest {
  username: string;
  password: string;
}

/**
 * User information model
 */
export interface UserInfo {
  userId: number;
  username: string;
  email: string;
  fullName: string;
  roles: string[];
}

/**
 * Login response model
 */
export interface LoginResponse {
  isValid: boolean;
  message: string;
  token?: string;
  user?: UserInfo;
}

/**
 * Validates user credentials by calling the .NET 8 Web API endpoint.
 * 
 * @param username - The username to validate
 * @param password - The password to validate
 * @returns A promise that resolves to a LoginResponse
 * @throws Error if the API call fails
 * 
 * @example
 * const response = await validateUser('admin', 'password');
 * if (response.isValid) {
 *   console.log('User logged in:', response.user);
 *   localStorage.setItem('authToken', response.token);
 * } else {
 *   console.error('Login failed:', response.message);
 * }
 */
export const validateUser = async (username: string, password: string): Promise<LoginResponse> => {
  try {
    const response = await apiClient.post<LoginResponse>(
      'api/Auth/ValidateUser',
      {
        username,
        password,
      }
    );
    return response.data;
  } catch (error) {
    console.error('Error validating user:', error);
    throw error;
  }
};

/**
 * Clears authentication token and user info from storage.
 */
export const logout = (): void => {
  localStorage.removeItem('authToken');
  localStorage.removeItem('user');
};

/**
 * Retrieves stored auth token from local storage.
 * @returns The auth token or null if not found
 */
export const getAuthToken = (): string | null => {
  return localStorage.getItem('authToken');
};

/**
 * Stores auth token and user info in local storage.
 * @param token - The authentication token
 * @param user - The user information
 */
export const setAuthData = (token: string, user: UserInfo): void => {
  localStorage.setItem('authToken', token);
  localStorage.setItem('user', JSON.stringify(user));
};
