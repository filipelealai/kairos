export interface AgentMessage {
  role: "user" | "assistant";
  content: string;
}

export interface AgentOptions {
  model?: string;
  maxTokens?: number;
  systemPrompt?: string;
}

export interface TaskResult {
  success: boolean;
  output: string;
  error?: string;
}
