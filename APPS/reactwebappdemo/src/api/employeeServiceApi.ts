import  apiClient  from './apiBase';

export interface Employee {
    id: number;
    employee_name: string;
    employee_salary: string;
    employee_age: string;
    profile_image: string;
}

export interface EmployeeResponse {
    status: string;
    data: Employee[];
}

export const getEmployees = async (): Promise<Employee[]> => {
    try {
        const response = await apiClient.get<EmployeeResponse>(
            'https://dummy.restapiexample.com/api/v1/employees'
        );
        return response.data.data;
    } catch (error) {
        console.error('Error fetching employees:', error);
        throw error;
    }
}