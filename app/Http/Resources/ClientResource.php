<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class ClientResource extends JsonResource
{
    /**
     * Transform the resource into an array.
     *
     * @return array<string, mixed>
     */
   public function toArray($request)
{
    return [
        'id' => $this->id,
        'nom_entreprise' => $this->nom_entreprise,
        'contact' => $this->contact,
        'telephone' => $this->telephone,
        'email' => $this->email,
        'adresse' => $this->adresse,
    ];
}

}
