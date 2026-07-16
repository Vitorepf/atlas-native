import test from "node:test";
import assert from "node:assert/strict";
import fs from "node:fs";
import vm from "node:vm";

const html = fs.readFileSync("docs/proposals/codex-execucao-viva/index.html", "utf8");
const source = html.match(/\/\* QUEUE_STATE_START \*\/([\s\S]*?)\/\* QUEUE_STATE_END \*\//)?.[1];
assert.ok(source, "queue state source must exist inside the standalone proposal");
const context = {};
vm.createContext(context);
vm.runInContext(`${source};globalThis.createQueueModel=createQueueModel`, context);

const experienceSource = html.match(/\/\* EXPERIENCE_STATE_START \*\/([\s\S]*?)\/\* EXPERIENCE_STATE_END \*\//)?.[1];
assert.ok(experienceSource, "experience player state must exist inside the final proposal");
vm.runInContext(`${experienceSource};globalThis.createExperienceModel=createExperienceModel`, context);

test("send while executing appends and preserves FIFO order", () => {
  const queue = context.createQueueModel();
  queue.enqueue("primeira");
  queue.enqueue("segunda");
  assert.deepEqual(Array.from(queue.items(), item => item.text), ["primeira", "segunda"]);
});

test("empty messages are ignored", () => {
  const queue = context.createQueueModel();
  assert.equal(queue.enqueue("   "), null);
  assert.equal(queue.count(), 0);
});

test("promote and remove affect only the selected item", () => {
  const queue = context.createQueueModel();
  const first = queue.enqueue("primeira");
  const second = queue.enqueue("segunda");
  assert.equal(queue.promote(second.id).text, "segunda");
  assert.deepEqual(Array.from(queue.items(), item => item.text), ["primeira"]);
  assert.equal(queue.remove(first.id), true);
  assert.equal(queue.count(), 0);
});

test("all existing proposal surfaces remain present", () => {
  for (const label of [
    "1. Dentro do app",
    "2. Fora do app",
    "3. Estados terminais e recuperação",
    "Nove situações",
    "01 · Orquestra de agentes",
    "02 · Replanejamento honesto",
    "03 · Atenção necessária",
    "04 · Aguardando sistema externo",
    "05 · Reconexão e recuperação",
    "06 · Artefato pronto",
    "07 · LiveKit e voz contínua",
    "08 · Continuidade entre dispositivos",
    "09 · Revisão entre agentes",
  ]) {
    assert.ok(html.includes(label), `missing existing surface: ${label}`);
  }
});

test("the execution screen exposes the complete follow-up workflow", () => {
  for (const marker of [
    'id="followup-form"',
    'id="followup-input"',
    'id="queue-chip"',
    'id="queue-sheet"',
    'id="stop-execution"',
    "Enviar agora",
    "Remover",
  ]) {
    assert.ok(html.includes(marker), `missing follow-up control: ${marker}`);
  }
});

test("the final experience player preserves the complete narrative order", () => {
  const player = context.createExperienceModel();
  assert.deepEqual(Array.from(player.scenes()), ["executing", "queue", "redirect", "complete", "recovery"]);
  assert.equal(player.current(), "executing");
  assert.equal(player.select("complete"), "complete");
  assert.equal(player.next(), "recovery");
  assert.equal(player.next(), "executing");
});

test("the final presentation uses the Atlas brand and exposes every player state", () => {
  for (const marker of [
    'id="experience-player"',
    'data-ios-frame="huashu-ios-frame-v1"',
    'AppIcon.appiconset/icon-1024.png',
    'data-scene="executing"',
    'data-scene="queue"',
    'data-scene="redirect"',
    'data-scene="complete"',
    'data-scene="recovery"',
    'id="player-autoplay"',
    'id="player-queue-sheet"',
  ]) {
    assert.ok(html.includes(marker), `missing final experience marker: ${marker}`);
  }
});
