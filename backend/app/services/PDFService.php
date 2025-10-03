<?php
namespace App\Services;

use Dompdf\Dompdf;
use Dompdf\Options;

class PDFService {
    private $dompdf;

    public function __construct() {
        $options = new Options();
        $options->set('isHtml5ParserEnabled', true);
        $options->set('isRemoteEnabled', true);
        $this->dompdf = new Dompdf($options);
    }

    public function generateInvoice($html, $outputPath = null) {
        $this->dompdf->loadHtml($html);
        $this->dompdf->setPaper('A4', 'portrait');
        $this->dompdf->render();

        if ($outputPath) {
            file_put_contents($outputPath, $this->dompdf->output());
        } else {
            return $this->dompdf->stream('invoice.pdf', ['Attachment' => false]);
        }
    }
}
