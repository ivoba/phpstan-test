<?php

namespace App\Controller;

use DeepCopy\DeepCopy;
use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;
use Symfony\Component\HttpFoundation\Response;

class DefaultController extends AbstractController
{

    private DeepCopy $deepCopy;

    public function __construct(DeepCopy $deepCopy)
    {
        $this->deepCopy = $deepCopy;
    }

    public function index()
    {
        $obj   = new \stdClass();
        $other = $this->deepCopy->copy($obj);

        return new Response('<html><body>Hi!</body></html>');
    }
}
