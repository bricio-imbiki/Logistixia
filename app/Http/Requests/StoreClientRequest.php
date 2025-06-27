<?php
namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class StoreClientRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true; // ✅ autorisation activée
    }

    public function rules(): array
    {
        return [
            'nom_entreprise' => 'required|string|max:100',
            'contact' => 'nullable|string|max:100',
            'telephone' => 'nullable|string|max:20',
            'email' => 'nullable|email|max:100',
            'adresse' => 'nullable|string'
        ];
    }
}
