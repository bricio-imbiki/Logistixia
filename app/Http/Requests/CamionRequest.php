<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class CamionRequest extends FormRequest
{
    /**
     * Determine if the user is authorized to make this request.
     */
    public function authorize(): bool
    {
        return false;
    }

    /**
     * Get the validation rules that apply to the request.
     *
     * @return array<string, \Illuminate\Contracts\Validation\ValidationRule|array<mixed>|string>
     */
   public function rules()
{
    return [
        'matricule' => 'required|string|unique:camions',
        'marque' => 'nullable|string',
        'modele' => 'nullable|string',
        'capacite_kg' => 'nullable|integer',
        'statut' => 'in:disponible,en mission,panne,maintenance',
        'est_interne' => 'boolean',
        'societe_proprietaire' => 'nullable|string'
    ];
}

}
