<?php
namespace App\Services;

use App\Repositories\Interfaces\ClientRepositoryInterface;

class ClientService {
    protected $clientRepo;

    public function __construct(ClientRepositoryInterface $clientRepo) {
        $this->clientRepo = $clientRepo;
    }

    public function getAllClients() {
        return $this->clientRepo->all();
    }

    public function store(array $data) {
        return $this->clientRepo->create($data);
    }

    public function update($id, array $data) {
        return $this->clientRepo->update($id, $data);
    }

    public function delete($id) {
        return $this->clientRepo->delete($id);
    }
}
