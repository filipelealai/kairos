import Anthropic from "@anthropic-ai/sdk";
import type { AgentMessage, AgentOptions, TaskResult } from "../types/index.js";

const client = new Anthropic({
  apiKey: process.env.ANTHROPIC_API_KEY,
});

const DEFAULT_MODEL = "claude-sonnet-4-6";
const DEFAULT_MAX_TOKENS = 8096;

export async function ask(
  prompt: string,
  options: AgentOptions = {}
): Promise<string> {
  const response = await client.messages.create({
    model: options.model ?? DEFAULT_MODEL,
    max_tokens: options.maxTokens ?? DEFAULT_MAX_TOKENS,
    system: options.systemPrompt,
    messages: [{ role: "user", content: prompt }],
  });

  const block = response.content[0];
  if (block.type !== "text") throw new Error("Unexpected response type");
  return block.text;
}

export async function chat(
  messages: AgentMessage[],
  options: AgentOptions = {}
): Promise<string> {
  const response = await client.messages.create({
    model: options.model ?? DEFAULT_MODEL,
    max_tokens: options.maxTokens ?? DEFAULT_MAX_TOKENS,
    system: options.systemPrompt,
    messages,
  });

  const block = response.content[0];
  if (block.type !== "text") throw new Error("Unexpected response type");
  return block.text;
}

export async function run(
  task: string,
  systemPrompt: string,
  options: AgentOptions = {}
): Promise<TaskResult> {
  try {
    const output = await ask(task, { ...options, systemPrompt });
    return { success: true, output };
  } catch (err) {
    const error = err instanceof Error ? err.message : String(err);
    return { success: false, output: "", error };
  }
}
