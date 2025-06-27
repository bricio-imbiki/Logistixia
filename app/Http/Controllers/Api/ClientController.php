<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\StoreClientRequest;
use App\Http\Requests\UpdateClientRequest;
use App\Services\ClientService;

class ClientController extends Controller {
    protected $clientService;

    public function __construct(ClientService $clientService) {
        $this->clientService = $clientService;
    }

    public function index() {
        return response()->json($this->clientService->getAllClients());
    }

    public function store(StoreClientRequest $request) {
        return response()->json($this->clientService->store($request->validated()));
    }

    public function update(UpdateClientRequest $request, $id) {
        return response()->json($this->clientService->update($id, $request->validated()));
    }

    public function destroy($id) {
        return response()->json($this->clientService->delete($id));
    }
}
