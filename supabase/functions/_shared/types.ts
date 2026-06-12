export interface ThreatAnalysisRequest {
  architectureDescription: string;
  userId: string;
}

export interface Asset {
  id: string;
  name: string;
  description: string;
  type: string;
  sensitivity: string;
}

export interface Threat {
  id: string;
  assetId: string;
  title: string;
  description: string;
  strideCategory: string;
  status: string;
}

export interface DreadScore {
  threatId: string;
  damage: number;
  reproducibility: number;
  exploitability: number;
  affectedUsers: number;
  discoverability: number;
}

export interface Mitigation {
  id: string;
  threatId: string;
  description: string;
  priority: string;
  status: string;
}

export interface ThreatAnalysisResponse {
  assets: Asset[];
  threats: Threat[];
  dreadScores: DreadScore[];
  mitigations: Mitigation[];
}
