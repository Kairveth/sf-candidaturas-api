import { LightningElement, api, wire } from 'lwc';
import { getRecord, getFieldValue, notifyRecordUpdateAvailable } from 'lightning/uiRecordApi';
import { refreshApex } from '@salesforce/apex';
import ESTADO from '@salesforce/schema/Candidatura__c.Estado__c';
import transicionesPermitidas from '@salesforce/apex/CandidaturaEstadoController.transicionesPermitidas';
import cambiaEstado from '@salesforce/apex/CandidaturaEstadoController.cambiaEstado';

export default class CandidaturaEstado extends LightningElement {
    @api recordId;
    error;
    registro;
    botones;

    @wire(getRecord, { recordId: '$recordId', fields: [ESTADO] })
    cargaRegistro(resultado) {
        this.registro = resultado;
    }

    @wire(transicionesPermitidas, { candidaturaId: '$recordId' })
    cargaBotones(resultado) {
        this.botones = resultado;
    }

    get estado() {
        return this.registro && this.registro.data ? getFieldValue(this.registro.data, ESTADO) : '';
    }

    get listaBotones() {
        return this.botones && this.botones.data ? this.botones.data : [];
    }

    async handleClick(event) {
        this.error = undefined;
        try {
            await cambiaEstado({ candidaturaId: this.recordId, nuevoEstado: event.target.dataset.estado });
            await notifyRecordUpdateAvailable([{ recordId: this.recordId }]);
            await refreshApex(this.botones);
        } catch (e) {
            this.error = e.body ? e.body.message : e.message;
        }
    }
}