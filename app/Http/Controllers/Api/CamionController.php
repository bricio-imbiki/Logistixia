<?php


namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\CamionRequest;
use App\Http\Resources\CamionResource;
use App\Services\CamionService;

class CamionController extends Controller
{
    protected $service;

    public function __construct(CamionService $service)
    {
        $this->service = $service;
    }

    public function index()
    {
        return CamionResource::collection($this->service->list());
    }

    public function store(CamionRequest $request)
    {
        $camion = $this->service->create($request->validated());
        return new CamionResource($camion);
    }

    public function show($id)
    {
        return new CamionResource($this->service->get($id));
    }

    public function update(CamionRequest $request, $id)
    {
        $camion = $this->service->update($id, $request->validated());
        return new CamionResource($camion);
    }

    public function destroy($id)
    {
        $this->service->delete($id);
        return response()->json(null, 204);
    }
}

