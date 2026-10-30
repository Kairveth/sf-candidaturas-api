import { createElement } from "lwc";
import CandidaturaEstado from "c/candidaturaEstado";
import {
  registerApexTestWireAdapter,
  registerLdsTestWireAdapter
} from "@salesforce/sfdx-lwc-jest";
import { getRecord } from "lightning/uiRecordApi";
import transicionesPermitidas from "@salesforce/apex/CandidaturaEstadoController.transicionesPermitidas";
import cambiaEstado from "@salesforce/apex/CandidaturaEstadoController.cambiaEstado";

jest.mock(
  "@salesforce/apex/CandidaturaEstadoController.cambiaEstado",
  () => ({ default: jest.fn() }),
  { virtual: true }
);

const registroAdapter = registerLdsTestWireAdapter(getRecord);
const transicionesAdapter = registerApexTestWireAdapter(transicionesPermitidas);
const ID = "a00000000000000AAA";

function monta() {
  const element = createElement("c-candidatura-estado", {
    is: CandidaturaEstado
  });
  element.recordId = ID;
  document.body.appendChild(element);
  registroAdapter.emit({
    fields: { Estado__c: { value: "Recibida", displayValue: null } }
  });
  return element;
}

function botones(element) {
  return [...element.shadowRoot.querySelectorAll("lightning-button")];
}

async function esperaRender() {
  await Promise.resolve();
  await Promise.resolve();
}

describe("c-candidatura-estado", () => {
  afterEach(() => {
    while (document.body.firstChild) {
      document.body.removeChild(document.body.firstChild);
    }
    jest.clearAllMocks();
  });

  it("muestra el estado actual del registro", async () => {
    const element = monta();
    await esperaRender();
    expect(element.shadowRoot.querySelector("strong").textContent).toBe(
      "Recibida"
    );
  });

  it("muestra un botón por cada transición permitida", async () => {
    const element = monta();
    transicionesAdapter.emit(["En revisión", "Descartada"]);
    await esperaRender();
    expect(botones(element).map((b) => b.label)).toEqual([
      "En revisión",
      "Descartada"
    ]);
  });

  it("al pulsar un botón llama a cambiaEstado con el id y el nuevo estado", async () => {
    cambiaEstado.mockResolvedValue();
    const element = monta();
    transicionesAdapter.emit(["Entrevista"]);
    await esperaRender();
    botones(element)[0].click();
    await esperaRender();
    expect(cambiaEstado).toHaveBeenCalledWith({
      candidaturaId: ID,
      nuevoEstado: "Entrevista"
    });
  });

  it("muestra el mensaje de error si cambiaEstado falla", async () => {
    cambiaEstado.mockRejectedValue({
      body: { message: "Transición no válida" }
    });
    const element = monta();
    transicionesAdapter.emit(["Entrevista"]);
    await esperaRender();
    botones(element)[0].click();
    await esperaRender();
    const error = element.shadowRoot.querySelector(".slds-text-color_error");
    expect(error.textContent).toBe("Transición no válida");
  });
});
