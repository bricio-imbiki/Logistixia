<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class CamionResource extends JsonResource
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
        'matricule' => $this->matricule,
        'marque' => $this->marque,
        'modele' => $this->modele,
        'capacite_kg' => $this->capacite_kg,
        'statut' => $this->statut,
        'est_interne' => $this->est_interne,
        'societe_proprietaire' => $this->societe_proprietaire
    ];
}
}
