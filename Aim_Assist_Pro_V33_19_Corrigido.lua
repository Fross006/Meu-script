-- V34.3.0 — configurações reconstruídas com início, busca e grupos por assunto.
-- Toque no valor para digitar ou use + / − para ajustar uma unidade.
-- Limites, valores salvos e callbacks das opções preservados.
-- Direita escolhe o próximo alvo à direita; Inverter gesto muda o sentido.
-- Cada novo trecho do deslize pode trocar de alvo sem soltar o dedo.
-- Toque parado não repete a troca; aquisição e mira continuam independentes.
-- Demais opções e configurações existentes preservadas.
--==============================================================
-- SERVICES / ROOT STATE
--==============================================================

local S = {
	Players = game:GetService("Players"),
	RunService = game:GetService("RunService"),
	UIS = game:GetService("UserInputService"),
	TweenService = game:GetService("TweenService"),
	Workspace = game:GetService("Workspace"),
	Teams = game:GetService("Teams"),
	Stats = game:GetService("Stats"),
	HttpService = game:GetService("HttpService"),
}

S.LocalPlayer = S.Players.LocalPlayer
S.PlayerGui = S.LocalPlayer:WaitForChild("PlayerGui")
S.Camera = S.Workspace.CurrentCamera

-- Keep every menu-size entry point on the same validated range. The lower
-- bound remains usable on a phone, while the upper bound can still grow on
-- tablets without pushing the window outside the viewport.
local MENU_SCALE_MIN = 0.70
local MENU_SCALE_MAX = 1.18
local CONTROL_SCALE_MIN = 0.82
local CONTROL_SCALE_MAX = 1.12

local MENU_LAYOUT_PRESETS = {
	BALANCED = {
		Label = "EQUILIBRADO",
		Description = "Divide o espaço entre menu, estado e jogadores.",
		Left = 0.18,
		Center = 0.64,
		Right = 0.18,
	},
	FOCUS = {
		Label = "MENU MAIOR",
		Description = "Dá mais espaço para as opções e esconde a lista lateral.",
		Left = 0.20,
		Center = 0.80,
		Right = 0,
	},
	TARGETS = {
		Label = "JOGADORES MAIOR",
		Description = "Aumenta a lista lateral de jogadores.",
		Left = 0.16,
		Center = 0.60,
		Right = 0.24,
	},
	CLEAN = {
		Label = "SÓ O MENU",
		Description = "Mostra apenas o menu principal e a barra de estado.",
		Left = 0.14,
		Center = 0.86,
		Right = 0,
	},
}

local FOV_STYLE_ORDER = {
	"RING",
	"DOT",
	"CROSS",
	"TACTICAL",
	"DUAL",
	"PRECISION",
}

local FOV_STYLE_LABELS = {
	RING = "ANEL",
	DOT = "ANEL + PONTO",
	CROSS = "MIRA CRUZADA",
	TACTICAL = "TÁTICO",
	DUAL = "ANEL DUPLO",
	PRECISION = "MIRA FINA",
}

local Config = {
	AimEnabled = false,
	AimMode = "AUTO",
	MobileQuickControls = true,
	MobileQuickLocked = true,
	UITheme = "RED",
	MenuScale = 0.92,
	MenuCustomWidth = 0,
	MenuCustomHeight = 0,
	MenuSizeMode = "BALANCED",
	MenuLayoutStyle = "BALANCED",
	ControlScale = 0.90,
	MenuControlLayout = {},
	TapSelectPlayer = false,
	TapSelectPadding = 8,
	TapSelectMoveThreshold = 14,
	TapSelectMaxDuration = 0.46,
	MobileFriendlySwitch = false,
	MobileFriendlyMoveThreshold = 36,
	MobileFriendlyInvertGesture = false,
	MobileFriendlyRadius = 165,
	MobileFriendlyHorizontalRatio = 1.05,
	MobileFriendlyStartArea = 0.28,
	MobileFriendlyGestureTimeout = 3.0,
	MobileFriendlyTransitionMin = 0.12,
	MobileFriendlyTransitionMax = 0.30,
	MobileFriendlyStreamDistance = 650,

	WallCheck = true,
	Prediction = true,
	PredictionMode = "AUTO",
	PredictionTime = 0.055,
	PredictionMin = 0.018,
	PredictionMax = 0.120,

	Accuracy = 100,
	AimStrength = 100,
	HorizontalStrength = 100,
	VerticalStrength = 100,
	Smoothing = 0,
	SmoothingCurve = "DYNAMIC",

	DistanceCompensation = true,
	DistanceStrengthMin = 0.72,
	DistanceStrengthMax = 1.00,

	FOVEnabled = true,
	FOV = 220,
	FOVStyle = "TACTICAL",
	ShowFOVCircle = true,
	RetentionFOVMultiplier = 1.95,
	OnScreenOnly = true,

	StickyTarget = true,
	StickyGrace = 0.32,
	WallGrace = 0,
	StrictWallCheck = true,
	RenderWallValidation = true,
	WallPassthroughLimit = 12,
	TargetSwitchPenalty = 145,
	MaxBodyCandidates = 16,

	-- Frame-rate independent camera response.
	ResponseSpeed = 44,
	SnapAtMaximum = true,

	WeaponProfile = "DEFAULT",
	WeaponProfiles = {
		DEFAULT = {
			Strength = 100,
			Smoothing = 0,
			PredictionScale = 1.00,
			FOVScale = 1.00,
		},
		RIFLE = {
			Strength = 92,
			Smoothing = 8,
			PredictionScale = 1.00,
			FOVScale = 1.00,
		},
		SMG = {
			Strength = 88,
			Smoothing = 12,
			PredictionScale = 0.92,
			FOVScale = 1.12,
		},
		SNIPER = {
			Strength = 100,
			Smoothing = 0,
			PredictionScale = 1.12,
			FOVScale = 0.72,
		},
		PISTOL = {
			Strength = 94,
			Smoothing = 6,
			PredictionScale = 0.96,
			FOVScale = 0.92,
		},
		SHOTGUN = {
			Strength = 98,
			Smoothing = 2,
			PredictionScale = 0.88,
			FOVScale = 1.20,
		},
		DMR = {
			Strength = 96,
			Smoothing = 4,
			PredictionScale = 1.08,
			FOVScale = 0.82,
		},
		LMG = {
			Strength = 86,
			Smoothing = 14,
			PredictionScale = 1.02,
			FOVScale = 1.05,
		},
		PROJECTILE = {
			Strength = 90,
			Smoothing = 10,
			PredictionScale = 1.25,
			FOVScale = 0.90,
		},
	},

	-- Presets are intended for authorized aim-assistance mechanics inside
	-- the experience. They never change player/team filters or ESP settings.
	AimAssistant = {
		Weapon = "RIFLE",
		Mode = "BALANCED",
		Applied = false,
		Customized = false,

		WeaponOrder = {
			"RIFLE",
			"SMG",
			"SNIPER",
			"SHOTGUN",
			"PISTOL",
			"DMR",
			"LMG",
			"PROJECTILE",
		},

		ModeOrder = {
			"SOFT",
			"BALANCED",
			"STRONG",
			"MAXIMUM",
		},

		Weapons = {
			RIFLE = {
				Label = "RIFLE",
				Description = "Uso geral e média distância.",
				Profile = "RIFLE",
				FOV = 230,
				PredictionMin = 0.016,
				PredictionMax = 0.100,
				Primary = "Torso",
				StrengthOffset = 0,
				AccuracyOffset = 2,
				SmoothingOffset = 0,
				HorizontalOffset = 0,
				VerticalOffset = 0,
				ResponseOffset = 0,
				BodyPadding = 1.65,
				HeadPredictionScale = 0.40,
				LimbPredictionScale = 0.72,
				LongRange = true,
				LongRangeStart = 140,
				LongRangeFull = 650,
				HeadLift = 0.10,
			},
			SMG = {
				Label = "SMG",
				Description = "Combate rápido e de perto.",
				Profile = "SMG",
				FOV = 300,
				PredictionMin = 0.014,
				PredictionMax = 0.085,
				Primary = "Torso",
				StrengthOffset = 7,
				AccuracyOffset = -3,
				SmoothingOffset = -7,
				HorizontalOffset = 6,
				VerticalOffset = 3,
				ResponseOffset = 7,
				BodyPadding = 1.80,
				HeadPredictionScale = 0.50,
				LimbPredictionScale = 0.82,
				LongRange = false,
				LongRangeStart = 180,
				LongRangeFull = 520,
				HeadLift = 0.06,
			},
			SNIPER = {
				Label = "SNIPER",
				Description = "Tiros precisos de longa distância.",
				Profile = "SNIPER",
				FOV = 170,
				PredictionMin = 0.024,
				PredictionMax = 0.120,
				Primary = "Head",
				StrengthOffset = -8,
				AccuracyOffset = 6,
				SmoothingOffset = 8,
				HorizontalOffset = -7,
				VerticalOffset = -4,
				ResponseOffset = -4,
				BodyPadding = 1.42,
				HeadPredictionScale = 0.32,
				LimbPredictionScale = 0.62,
				LongRange = true,
				LongRangeStart = 80,
				LongRangeFull = 800,
				HeadLift = 0.12,
			},
			SHOTGUN = {
				Label = "ESCOPETA",
				Description = "Tiros fortes de curta distância.",
				Profile = "SHOTGUN",
				FOV = 330,
				PredictionMin = 0.010,
				PredictionMax = 0.070,
				Primary = "Torso",
				StrengthOffset = 10,
				AccuracyOffset = -7,
				SmoothingOffset = -10,
				HorizontalOffset = 8,
				VerticalOffset = 6,
				ResponseOffset = 8,
				BodyPadding = 2.00,
				HeadPredictionScale = 0.58,
				LimbPredictionScale = 0.90,
				LongRange = false,
				LongRangeStart = 220,
				LongRangeFull = 500,
				HeadLift = 0.04,
			},
			PISTOL = {
				Label = "PISTOLA",
				Description = "Controle simples em média distância.",
				Profile = "PISTOL",
				FOV = 210,
				PredictionMin = 0.016,
				PredictionMax = 0.100,
				Primary = "Head",
				StrengthOffset = -1,
				AccuracyOffset = 4,
				SmoothingOffset = 4,
				HorizontalOffset = -2,
				VerticalOffset = -1,
				ResponseOffset = -1,
				BodyPadding = 1.55,
				HeadPredictionScale = 0.42,
				LimbPredictionScale = 0.72,
				LongRange = true,
				LongRangeStart = 130,
				LongRangeFull = 620,
				HeadLift = 0.09,
			},
			DMR = {
				Label = "DMR",
				Description = "Tiros rápidos em média ou longa distância.",
				Profile = "DMR",
				FOV = 185,
				PredictionMin = 0.022,
				PredictionMax = 0.118,
				Primary = "Head",
				StrengthOffset = -5,
				AccuracyOffset = 6,
				SmoothingOffset = 6,
				HorizontalOffset = -5,
				VerticalOffset = -2,
				ResponseOffset = -3,
				BodyPadding = 1.48,
				HeadPredictionScale = 0.34,
				LimbPredictionScale = 0.65,
				LongRange = true,
				LongRangeStart = 100,
				LongRangeFull = 750,
				HeadLift = 0.11,
			},
			LMG = {
				Label = "LMG",
				Description = "Acompanha o alvo durante disparos longos.",
				Profile = "LMG",
				FOV = 260,
				PredictionMin = 0.018,
				PredictionMax = 0.105,
				Primary = "Torso",
				StrengthOffset = 3,
				AccuracyOffset = -2,
				SmoothingOffset = 5,
				HorizontalOffset = 4,
				VerticalOffset = 2,
				ResponseOffset = -2,
				BodyPadding = 1.75,
				HeadPredictionScale = 0.48,
				LimbPredictionScale = 0.78,
				LongRange = true,
				LongRangeStart = 160,
				LongRangeFull = 680,
				HeadLift = 0.08,
			},
			PROJECTILE = {
				Label = "PROJÉTIL",
				Description = "Para arcos, lançadores e tiros lentos.",
				Profile = "PROJECTILE",
				FOV = 240,
				PredictionMin = 0.032,
				PredictionMax = 0.140,
				Primary = "Torso",
				StrengthOffset = -6,
				AccuracyOffset = 3,
				SmoothingOffset = 10,
				HorizontalOffset = -5,
				VerticalOffset = -3,
				ResponseOffset = -5,
				BodyPadding = 1.90,
				HeadPredictionScale = 0.75,
				LimbPredictionScale = 1.00,
				LongRange = true,
				LongRangeStart = 90,
				LongRangeFull = 850,
				HeadLift = 0.14,
			},
		},

		Modes = {
			SOFT = {
				Label = "SUAVE",
				Description = "Pouca ajuda e movimento discreto.",
				Strength = 52,
				Accuracy = 78,
				Smoothing = 52,
				Horizontal = 65,
				Vertical = 62,
				Response = 24,
				FOVScale = 0.78,
				StickyGrace = 0.18,
				SwitchPenalty = 85,
				PrimaryBias = 105,
				CenterBias = 22,
				Retention = 1.45,
				DistanceMin = 0.58,
				Candidates = 10,
				PredictionBlend = 0.50,
				NearBlend = 0.28,
				MicroBoost = 1.05,
				CenterTolerance = 3.20,
				ScreenPixels = 2.80,
				ScanInterval = 0.040,
			},
			BALANCED = {
				Label = "EQUILIBRADO",
				Description = "Ajuda média para uso geral.",
				Strength = 72,
				Accuracy = 90,
				Smoothing = 30,
				Horizontal = 80,
				Vertical = 77,
				Response = 36,
				FOVScale = 0.92,
				StickyGrace = 0.26,
				SwitchPenalty = 125,
				PrimaryBias = 150,
				CenterBias = 38,
				Retention = 1.72,
				DistanceMin = 0.68,
				Candidates = 14,
				PredictionBlend = 0.36,
				NearBlend = 0.18,
				MicroBoost = 1.18,
				CenterTolerance = 2.20,
				ScreenPixels = 1.80,
				ScanInterval = 0.030,
			},
			STRONG = {
				Label = "FORTE",
				Description = "Ajuda alta e resposta rápida.",
				Strength = 90,
				Accuracy = 98,
				Smoothing = 12,
				Horizontal = 94,
				Vertical = 91,
				Response = 50,
				FOVScale = 1.02,
				StickyGrace = 0.34,
				SwitchPenalty = 170,
				PrimaryBias = 205,
				CenterBias = 50,
				Retention = 1.95,
				DistanceMin = 0.76,
				Candidates = 18,
				PredictionBlend = 0.24,
				NearBlend = 0.10,
				MicroBoost = 1.32,
				CenterTolerance = 1.40,
				ScreenPixels = 1.00,
				ScanInterval = 0.022,
			},
			MAXIMUM = {
				Label = "MÁXIMO",
				Description = "Ajuda total e movimento imediato.",
				Strength = 100,
				Accuracy = 100,
				Smoothing = 0,
				Horizontal = 100,
				Vertical = 100,
				Response = 66,
				FOVScale = 1.12,
				StickyGrace = 0.40,
				SwitchPenalty = 210,
				PrimaryBias = 260,
				CenterBias = 65,
				Retention = 2.15,
				DistanceMin = 0.82,
				Candidates = 24,
				PredictionBlend = 0.16,
				NearBlend = 0.06,
				MicroBoost = 1.48,
				CenterTolerance = 0.75,
				ScreenPixels = 0.50,
				ScanInterval = 0.016,
			},
		},
	},

	PrimaryBodyRegion = "Head",
	PrimaryBodyPartName = "Head",
	BodyRigMode = "R15",
	StrictBodyRegion = true,
	BodyFallback = true,
	MultiPointBodyAim = true,

	-- Body targeting
	ExactBodyAim = true,
	PrimaryRegionBias = 180,
	CenterPointBias = 45,
	BodyAcquisitionPadding = 1.65,
	HeadPredictionScale = 0.40,
	LimbPredictionScale = 0.72,

	-- Precision response
	PreferPartCenter = true,
	ExactBodyPredictionBlend = 0.18,
	NearTargetPredictionBlend = 0.08,
	NearTargetRadius = 42,
	MicroCorrectionRadius = 18,
	MicroCorrectionBoost = 1.28,
	CenterLockTolerance = 1.25,

	-- Long-range correction
	LongRangeCorrection = true,
	LongRangeStart = 120,
	LongRangeFull = 650,
	LongRangeHeadLift = 0.10,
	ScreenConvergence = true,
	ScreenConvergencePixels = 0.75,
	LateRenderCorrection = true,

	BodyRegionWeights = {
		Head = 100,
		Torso = 85,
		LeftArm = 55,
		RightArm = 55,
		LeftLeg = 35,
		RightLeg = 35,
	},

	BodyRegionEnabled = {
		Head = true,
		Torso = true,
		LeftArm = true,
		RightArm = true,
		LeftLeg = true,
		RightLeg = true,
	},

	ESPEnabled = false,
	GlobalESP = false,
	ESPEnemies = true,
	ESPAllies = false,
	ESPUseTeamColors = false,
	SelectedESP = true,
	ESPLabels = true,

	DebugEnabled = false,
	DebugShowTargetLine = true,

	TargetScanInterval = 0.025,
	LabelUpdateInterval = 1 / 60,
	ESPDistanceMaxStep = 1.00,
	ESPRecoveryInterval = 0.75,

}

local Theme = {
	-- AAA dark-glass / crimson system matched to the visual reference.
	BG = Color3.fromRGB(5, 7, 11),
	Glass = Color3.fromRGB(9, 11, 17),
	GlassRaised = Color3.fromRGB(17, 19, 27),
	Surface2 = Color3.fromRGB(16, 18, 25),
	Surface3 = Color3.fromRGB(21, 23, 31),

	Card = Color3.fromRGB(14, 16, 23),
	CardHover = Color3.fromRGB(22, 24, 33),
	CardActive = Color3.fromRGB(47, 19, 29),

	Border = Color3.fromRGB(71, 75, 89),
	BorderSoft = Color3.fromRGB(43, 47, 59),
	BorderInner = Color3.fromRGB(98, 102, 116),

	Accent = Color3.fromRGB(245, 47, 85),
	Accent2 = Color3.fromRGB(255, 103, 124),
	AccentHot = Color3.fromRGB(255, 35, 72),
	AccentSoft = Color3.fromRGB(84, 20, 37),
	AccentDeep = Color3.fromRGB(30, 9, 17),

	Success = Color3.fromRGB(56, 190, 118),
	Danger = Color3.fromRGB(225, 84, 96),
	Warning = Color3.fromRGB(221, 166, 74),

	Text = Color3.fromRGB(248, 249, 252),
	Sub = Color3.fromRGB(177, 181, 193),
	Muted = Color3.fromRGB(105, 112, 130),
	Dim = Color3.fromRGB(72, 79, 96),

	Chip = Color3.fromRGB(18, 22, 29),
}

local ThemePresets = {
	RED = {
		Label = "VERMELHO",
		CardActive = Color3.fromRGB(47, 19, 29),
		Accent = Color3.fromRGB(245, 47, 85),
		Accent2 = Color3.fromRGB(255, 103, 124),
		AccentHot = Color3.fromRGB(255, 35, 72),
		AccentSoft = Color3.fromRGB(84, 20, 37),
		AccentDeep = Color3.fromRGB(30, 9, 17),
	},
	BLUE = {
		Label = "AZUL",
		CardActive = Color3.fromRGB(18, 34, 57),
		Accent = Color3.fromRGB(53, 132, 255),
		Accent2 = Color3.fromRGB(115, 177, 255),
		AccentHot = Color3.fromRGB(33, 111, 255),
		AccentSoft = Color3.fromRGB(22, 49, 91),
		AccentDeep = Color3.fromRGB(8, 20, 42),
	},
	PURPLE = {
		Label = "ROXO",
		CardActive = Color3.fromRGB(37, 23, 54),
		Accent = Color3.fromRGB(166, 83, 244),
		Accent2 = Color3.fromRGB(206, 142, 255),
		AccentHot = Color3.fromRGB(148, 58, 239),
		AccentSoft = Color3.fromRGB(59, 29, 88),
		AccentDeep = Color3.fromRGB(25, 11, 40),
	},
	GREEN = {
		Label = "VERDE",
		CardActive = Color3.fromRGB(17, 44, 34),
		Accent = Color3.fromRGB(45, 198, 126),
		Accent2 = Color3.fromRGB(105, 232, 169),
		AccentHot = Color3.fromRGB(27, 181, 105),
		AccentSoft = Color3.fromRGB(18, 70, 48),
		AccentDeep = Color3.fromRGB(7, 31, 20),
	},
	ORANGE = {
		Label = "LARANJA",
		CardActive = Color3.fromRGB(48, 31, 18),
		Accent = Color3.fromRGB(245, 139, 48),
		Accent2 = Color3.fromRGB(255, 187, 105),
		AccentHot = Color3.fromRGB(255, 116, 25),
		AccentSoft = Color3.fromRGB(88, 48, 18),
		AccentDeep = Color3.fromRGB(39, 19, 7),
	},
	CYAN = {
		Label = "CIANO",
		CardActive = Color3.fromRGB(15, 39, 47),
		Accent = Color3.fromRGB(40, 190, 220),
		Accent2 = Color3.fromRGB(105, 224, 244),
		AccentHot = Color3.fromRGB(21, 170, 205),
		AccentSoft = Color3.fromRGB(16, 65, 77),
		AccentDeep = Color3.fromRGB(6, 27, 34),
	},
}

local RelationColors = {
	ENEMY = Color3.fromRGB(221, 94, 100),
	ALLY = Color3.fromRGB(91, 154, 213),
	NEUTRAL = Color3.fromRGB(212, 183, 104),
	SELF = Color3.fromRGB(150, 155, 166),
}

local WeaponProfileLabels = {
	DEFAULT = "PADRÃO",
	RIFLE = "RIFLE",
	SMG = "SMG",
	SNIPER = "SNIPER",
	PISTOL = "PISTOLA",
	SHOTGUN = "ESCOPETA",
	DMR = "DMR",
	LMG = "LMG",
	PROJECTILE = "PROJÉTIL",
}

local BodyRegions = {
	Head = {
		Label = "CABEÇA",
		Parts = {"Head"},
	},
	Torso = {
		Label = "TRONCO",
		Parts = {"UpperTorso", "LowerTorso", "Torso", "HumanoidRootPart"},
	},
	LeftArm = {
		Label = "BRAÇO ESQUERDO",
		Parts = {"LeftUpperArm", "LeftLowerArm", "LeftHand", "Left Arm"},
	},
	RightArm = {
		Label = "BRAÇO DIREITO",
		Parts = {"RightUpperArm", "RightLowerArm", "RightHand", "Right Arm"},
	},
	LeftLeg = {
		Label = "PERNA ESQUERDA",
		Parts = {"LeftUpperLeg", "LeftLowerLeg", "LeftFoot", "Left Leg"},
	},
	RightLeg = {
		Label = "PERNA DIREITA",
		Parts = {"RightUpperLeg", "RightLowerLeg", "RightFoot", "Right Leg"},
	},
}

local BodyRegionOrder = {
	"Head",
	"Torso",
	"LeftArm",
	"RightArm",
	"LeftLeg",
	"RightLeg",
}

local BodyRigProfiles = {
	R6 = {
		Label = "R6",
		RigType = Enum.HumanoidRigType.R6,
		Parts = {
			{Name = "Head", Label = "CABEÇA", Region = "Head"},
			{Name = "Torso", Label = "TRONCO", Region = "Torso"},
			{Name = "Left Arm", Label = "BRAÇO ESQUERDO", Region = "LeftArm"},
			{Name = "Right Arm", Label = "BRAÇO DIREITO", Region = "RightArm"},
			{Name = "Left Leg", Label = "PERNA ESQUERDA", Region = "LeftLeg"},
			{Name = "Right Leg", Label = "PERNA DIREITA", Region = "RightLeg"},
		},
	},
	R15 = {
		Label = "R15",
		RigType = Enum.HumanoidRigType.R15,
		Parts = {
			{Name = "Head", Label = "CABEÇA", Region = "Head"},
			{Name = "UpperTorso", Label = "TRONCO SUPERIOR", Region = "Torso"},
			{Name = "LowerTorso", Label = "TRONCO INFERIOR", Region = "Torso"},
			{Name = "LeftUpperArm", Label = "BRAÇO ESQ. SUPERIOR", Region = "LeftArm"},
			{Name = "LeftLowerArm", Label = "ANTEBRAÇO ESQUERDO", Region = "LeftArm"},
			{Name = "LeftHand", Label = "MÃO ESQUERDA", Region = "LeftArm"},
			{Name = "RightUpperArm", Label = "BRAÇO DIR. SUPERIOR", Region = "RightArm"},
			{Name = "RightLowerArm", Label = "ANTEBRAÇO DIREITO", Region = "RightArm"},
			{Name = "RightHand", Label = "MÃO DIREITA", Region = "RightArm"},
			{Name = "LeftUpperLeg", Label = "COXA ESQUERDA", Region = "LeftLeg"},
			{Name = "LeftLowerLeg", Label = "PERNA ESQUERDA", Region = "LeftLeg"},
			{Name = "LeftFoot", Label = "PÉ ESQUERDO", Region = "LeftLeg"},
			{Name = "RightUpperLeg", Label = "COXA DIREITA", Region = "RightLeg"},
			{Name = "RightLowerLeg", Label = "PERNA DIREITA", Region = "RightLeg"},
			{Name = "RightFoot", Label = "PÉ DIREITO", Region = "RightLeg"},
		},
	},
}

function BodyRigProfiles.Find(rigName, partName)
	local profile = BodyRigProfiles[rigName] or BodyRigProfiles.R15

	for _, entry in ipairs(profile.Parts) do
		if entry.Name == partName then
			return entry
		end
	end

	return nil
end

function BodyRigProfiles.DefaultForRegion(rigName, regionName)
	local profile = BodyRigProfiles[rigName] or BodyRigProfiles.R15

	for _, entry in ipairs(profile.Parts) do
		if entry.Region == regionName then
			return entry.Name
		end
	end

	return "Head"
end

function BodyRigProfiles.Normalize(rigName, partName, regionName)
	rigName = BodyRigProfiles[rigName] and rigName or "R15"
	local entry = BodyRigProfiles.Find(rigName, partName)

	if entry then
		return rigName, entry.Name, entry.Region
	end

	local fallback = BodyRigProfiles.DefaultForRegion(
		rigName,
		BodyRegions[regionName] and regionName or "Head"
	)

	entry = BodyRigProfiles.Find(rigName, fallback)
	return rigName, entry.Name, entry.Region
end

local BindImmediateESPCharacterEvents

local State = {
	SelectedPlayers = {},
	ManualAllies = {},
	Records = {},
	CurrentTarget = nil,
	CurrentPart = nil,
	CurrentRegion = nil,
	CurrentLocalOffset = nil,
	LastTargetSeen = 0,
	LastTargetVisible = 0,
	LastRenderedFOV = nil,
	LastViewportSize = nil,
	LastStatsUpdate = 0,
	SmoothedFPS = 60,
	PlayerListRefreshPending = false,
	RelationRefreshPending = false,
	RelationRefreshReason = nil,
	TargetSearchGeneration = 0,
	AimActivationIntent = Config.AimEnabled == true,
	AimScanRecoveries = 0,
	ESPRecoveries = 0,
	RenderRecoveries = 0,
	LastRuntimeError = nil,
	ActiveQuickPresetKey = nil,
	ThumbnailCache = {},
	ThumbnailPending = {},
	SessionConfigurations = {},
	Swipe = {Transition = nil, LastResult = "Nenhum gesto"},

	Debug = {
		LastReason = "Aguardando",
		LastScore = nil,
		LastRegion = nil,
		LastDistance = nil,
		Candidates = 0,
	},

	UI = {},
}

-- Named settings are persisted only inside a dedicated VisionX folder when
-- the host exposes guarded file APIs. In ordinary Roblox clients the exact
-- same interface remains available for the current session.
local Persistence = {
	Folder = "VisionX/Configs",
	Schema = 1,
}

function Persistence.DeepCopy(value, seen)
	if type(value) ~= "table" then
		return value
	end

	seen = seen or {}
	if seen[value] then
		return seen[value]
	end

	local copy = {}
	seen[value] = copy

	for key, child in pairs(value) do
		copy[Persistence.DeepCopy(key, seen)] =
			Persistence.DeepCopy(child, seen)
	end

	return copy
end

Persistence.DefaultConfig = Persistence.DeepCopy(Config)

function Persistence.FiniteNumber(value, fallback)
	local number = tonumber(value)

	if number == nil
		or number ~= number
		or number == math.huge
		or number == -math.huge then

		return fallback
	end

	return number
end

function Persistence.NormalizeConfig()
	local ranges = {
		Accuracy = {0, 100},
		AimStrength = {0, 100},
		HorizontalStrength = {0, 100},
		VerticalStrength = {0, 100},
		Smoothing = {0, 100},
		FOV = {10, 2000},
		RetentionFOVMultiplier = {1, 5},
		PredictionTime = {0, 0.5},
		PredictionMin = {0, 0.5},
		PredictionMax = {0, 0.5},
		StickyGrace = {0, 2},
		WallGrace = {0, 2},
		WallPassthroughLimit = {0, 100},
		MaxBodyCandidates = {1, 64},
		ResponseSpeed = {4, 120},
		TapSelectPadding = {0, 32},
		TapSelectMoveThreshold = {4, 64},
		TapSelectMaxDuration = {0.1, 1.5},
		MobileFriendlyMoveThreshold = {18, 180},
		MobileFriendlyRadius = {80, 400},
		MobileFriendlyHorizontalRatio = {0.75, 3},
		MobileFriendlyStartArea = {0.25, 0.70},
		MobileFriendlyGestureTimeout = {1, 8},
		MobileFriendlyTransitionMin = {0.05, 0.60},
		MobileFriendlyTransitionMax = {0.08, 0.80},
		MobileFriendlyStreamDistance = {100, 10000},
		MenuCustomWidth = {0, 1500},
		MenuCustomHeight = {0, 820},
		ControlScale = {CONTROL_SCALE_MIN, CONTROL_SCALE_MAX},
		TargetScanInterval = {1 / 240, 1},
		LabelUpdateInterval = {1 / 60, 1},
		ESPRecoveryInterval = {0.1, 10},
		DistanceStrengthMin = {0, 1},
		DistanceStrengthMax = {0, 1},
		TargetSwitchPenalty = {0, 1000},
		PrimaryRegionBias = {0, 1000},
		CenterPointBias = {0, 500},
		BodyAcquisitionPadding = {0.5, 5},
		HeadPredictionScale = {0, 3},
		LimbPredictionScale = {0, 3},
		ExactBodyPredictionBlend = {0, 1},
		NearTargetPredictionBlend = {0, 1},
		NearTargetRadius = {0, 500},
		MicroCorrectionRadius = {0, 500},
		MicroCorrectionBoost = {0, 5},
		CenterLockTolerance = {0, 50},
		LongRangeStart = {0, 9999},
		LongRangeFull = {1, 10000},
		LongRangeHeadLift = {0, 1},
		ScreenConvergencePixels = {0, 50},
	}

	for key, bounds in pairs(ranges) do
		Config[key] = math.clamp(
			Persistence.FiniteNumber(
				Config[key],
				Persistence.FiniteNumber(
					Persistence.DefaultConfig[key],
					bounds[1]
				)
			),
			bounds[1],
			bounds[2]
		)
	end

	Config.PredictionMin = math.min(
		Config.PredictionMin,
		Config.PredictionMax
	)
	Config.DistanceStrengthMin = math.min(
		Config.DistanceStrengthMin,
		Config.DistanceStrengthMax
	)
	Config.LongRangeFull = math.max(
		Config.LongRangeFull,
		Config.LongRangeStart + 1
	)
	Config.WallPassthroughLimit = math.floor(
		Config.WallPassthroughLimit + 0.5
	)
	Config.MaxBodyCandidates = math.floor(
		Config.MaxBodyCandidates + 0.5
	)
	Config.TapSelectPadding = math.floor(Config.TapSelectPadding + 0.5)
	Config.TapSelectMoveThreshold = math.floor(
		Config.TapSelectMoveThreshold + 0.5
	)
	Config.MobileFriendlyMoveThreshold = math.floor(
		Config.MobileFriendlyMoveThreshold + 0.5
	)
	Config.MobileFriendlyRadius = math.floor(
		Config.MobileFriendlyRadius + 0.5
	)
	Config.MobileFriendlySwitch = Config.MobileFriendlySwitch == true
	Config.MobileFriendlyTransitionMax = math.max(
		Config.MobileFriendlyTransitionMax,
		Config.MobileFriendlyTransitionMin
	)
	Config.ESPDistanceMaxStep = 1
	Config.AimMode = Config.AimMode == "SELECTED" and "SELECTED" or "AUTO"
	Config.PredictionMode =
		Config.PredictionMode == "MANUAL" and "MANUAL" or "AUTO"
	Config.SmoothingCurve =
		Config.SmoothingCurve == "LINEAR" and "LINEAR" or "DYNAMIC"
	Config.UITheme = ThemePresets[Config.UITheme] and Config.UITheme or "RED"
	Config.MenuLayoutStyle =
		MENU_LAYOUT_PRESETS[Config.MenuLayoutStyle]
		and Config.MenuLayoutStyle
		or "BALANCED"
	Config.MenuSizeMode =
		(
			Config.MenuSizeMode == "COMPACT"
			or Config.MenuSizeMode == "BALANCED"
			or Config.MenuSizeMode == "LARGE"
			or Config.MenuSizeMode == "CUSTOM"
		)
		and Config.MenuSizeMode
		or "BALANCED"
	Config.FOVStyle =
		FOV_STYLE_LABELS[Config.FOVStyle]
		and Config.FOVStyle
		or "TACTICAL"
	-- Saved files created before this option existed must keep the original
	-- visible-circle behavior. Hiding the graphic never disables FOV checks.
	Config.ShowFOVCircle = Config.ShowFOVCircle ~= false
	Config.MenuScale = math.clamp(
		Persistence.FiniteNumber(Config.MenuScale, 1),
		MENU_SCALE_MIN,
		MENU_SCALE_MAX
	)
	Config.ControlScale = math.clamp(
		Persistence.FiniteNumber(Config.ControlScale, 0.90),
		CONTROL_SCALE_MIN,
		CONTROL_SCALE_MAX
	)
	Config.MenuControlLayout =
		type(Config.MenuControlLayout) == "table"
		and Config.MenuControlLayout
		or {}

	if Config.MenuCustomWidth <= 0
		or Config.MenuCustomHeight <= 0 then

		Config.MenuCustomWidth = 0
		Config.MenuCustomHeight = 0
	end

	if not Config.WeaponProfiles[Config.WeaponProfile] then
		Config.WeaponProfile = Persistence.DefaultConfig.WeaponProfile
	end

	local assistant = Config.AimAssistant
	if not assistant.Weapons[assistant.Weapon] then
		assistant.Weapon = Persistence.DefaultConfig.AimAssistant.Weapon
	end
	if not assistant.Modes[assistant.Mode] then
		assistant.Mode = Persistence.DefaultConfig.AimAssistant.Mode
	end

	for regionName in pairs(BodyRegions) do
		local weight = Persistence.FiniteNumber(
			Config.BodyRegionWeights[regionName],
			0
		)
		if type(weight) ~= "number" then
			weight = 0
		end

		Config.BodyRegionWeights[regionName] = math.clamp(
			weight,
			0,
			100
		)
	end

	Config.BodyRigMode,
		Config.PrimaryBodyPartName,
		Config.PrimaryBodyRegion = BodyRigProfiles.Normalize(
			Config.BodyRigMode,
			Config.PrimaryBodyPartName,
			Config.PrimaryBodyRegion
		)
	Config.BodyRegionEnabled[Config.PrimaryBodyRegion] = true
end

function Persistence.SafeName(rawName)
	local name = tostring(rawName or ""):gsub("^%s+", ""):gsub("%s+$", "")
	-- Reject ambiguous filenames instead of silently removing characters or
	-- truncating two different names to the same destination.
	if name == "" or #name > 32 or name:find("[^%w _%-]") then
		return nil, "Use até 32 letras sem acento, números, espaços, - ou _."
	end
	return name
end

function Persistence.Path(name)
	return Persistence.Folder .. "/" .. name .. ".json"
end

function Persistence.HasDiskStorage()
	return type(writefile) == "function"
		and type(readfile) == "function"
		and type(listfiles) == "function"
		and type(makefolder) == "function"
		and S.HttpService ~= nil
end

function Persistence.EnsureFolder()
	if type(makefolder) ~= "function" then
		return false
	end

	pcall(makefolder, "VisionX")
	pcall(makefolder, Persistence.Folder)
	return true
end

function Persistence.DiskPathExists(path)
	if not Persistence.HasDiskStorage() then
		return false
	end

	if type(isfile) == "function" then
		local ok, exists = pcall(isfile, path)
		if ok then
			return exists == true
		end
	end

	local ok, files = pcall(listfiles, Persistence.Folder)
	if not ok or type(files) ~= "table" then
		return false
	end

	local normalizedPath = tostring(path):gsub("\\", "/")
	local targetFileName = normalizedPath:match("([^/]+)$")
	for _, filePath in ipairs(files) do
		local normalizedFilePath = tostring(filePath):gsub("\\", "/")
		if normalizedFilePath == normalizedPath
			or normalizedFilePath:match("([^/]+)$") == targetFileName then

			return true
		end
	end

	return false
end

function Persistence.SanitizeTable(template, source, path)
	if type(template) ~= "table" then
		if type(template) == "number" then
			if type(source) ~= "number" then
				return template
			end

			return Persistence.FiniteNumber(source, template)
		end

		if type(source) == type(template) then
			return source
		end

		return Persistence.DeepCopy(template)
	end

	local result = Persistence.DeepCopy(template)
	if type(source) ~= "table" then
		return result
	end

	if path == "MenuControlLayout" then
		result = {}
		local count = 0

		for controlId, entry in pairs(source) do
			if count >= 128 then
				break
			end

			if type(controlId) == "string"
				and #controlId <= 96
				and type(entry) == "table"
				and type(entry.Page) == "string"
				and #entry.Page <= 32
				and type(entry.Container) == "string"
				and #entry.Container <= 96 then

				result[controlId] = {
					Page = entry.Page,
					Container = entry.Container,
					Order = math.clamp(
						math.floor(
							Persistence.FiniteNumber(entry.Order, 100)
						),
						1,
						100000
					),
				}
				count += 1
			end
		end

		return result
	end

	for key, defaultValue in pairs(template) do
		if source[key] ~= nil then
			result[key] = Persistence.SanitizeTable(
				defaultValue,
				source[key],
				(path and (path .. ".") or "") .. tostring(key)
			)
		end
	end

	return result
end

function Persistence.ValidatePayload(payload)
	if type(payload) ~= "table" then
		return false, "Este arquivo não parece ser uma configuração válida."
	end
	if payload.Schema ~= nil and payload.Schema ~= Persistence.Schema then
		return false, "Esta configuração usa uma versão que o menu não reconhece."
	end
	local source = payload
	if payload.Config ~= nil then source = payload.Config end
	if type(source) ~= "table" then
		return false, "Os dados desta configuração estão incompletos."
	end
	local known = false
	for key, value in pairs(source) do
		if Persistence.DefaultConfig[key] ~= nil
			and type(value) == type(Persistence.DefaultConfig[key]) then
			known = true
			break
		end
	end
	if not known then
		return false, "Não há opções reconhecidas nesta configuração."
	end
	local stack = {{Value = payload, Depth = 1}}
	local seen = {}
	local nodes = 0
	while #stack > 0 do
		local entry = table.remove(stack)
		if entry.Depth > 16 or seen[entry.Value] then
			return false, "Esta configuração tem uma estrutura inválida."
		end
		seen[entry.Value] = true
		for key, value in pairs(entry.Value) do
			nodes += 1
			local kind = type(value)
			if nodes > 12000 or (type(key) ~= "string" and type(key) ~= "number")
				or (type(key) == "string" and #key > 256)
				or (kind == "string" and #value > 8192)
				or (kind ~= "table" and kind ~= "string" and kind ~= "number" and kind ~= "boolean") then
				return false, "Esta configuração é grande demais ou contém dados inválidos."
			end
			if kind == "table" then
				stack[#stack + 1] = {Value = value, Depth = entry.Depth + 1}
			end
		end
	end
	return true, source
end

function Persistence.ValidateJSONText(content)
	if type(content) ~= "string" or #content > 262144 then
		return false, "O arquivo precisa ter no máximo 256 KB."
	end
	local depth, inString, escaped = 0, false, false
	for index = 1, #content do
		local byte = string.byte(content, index)
		if inString then
			if escaped then escaped = false
			elseif byte == 92 then escaped = true
			elseif byte == 34 then inString = false end
		elseif byte == 34 then
			inString = true
		elseif byte == 123 or byte == 91 then
			depth += 1
			if depth > 16 then
				return false, "Esta configuração tem camadas demais."
			end
		elseif byte == 125 or byte == 93 then
			depth -= 1
			if depth < 0 then return false, "O arquivo de configuração está incompleto." end
		end
	end
	if inString or depth ~= 0 then return false, "O arquivo de configuração está incompleto." end
	return true
end

function Persistence.Apply(source)
	local valid, result = Persistence.ValidatePayload(source)
	if not valid then return false, result end
	source = result

	local restored = Persistence.SanitizeTable(
		Persistence.DefaultConfig,
		source,
		nil
	)

	-- Preset definitions are code, not user settings. Keep these internal
	-- tables immutable even when a JSON file was edited outside the menu.
	restored.WeaponProfiles = Persistence.DeepCopy(
		Persistence.DefaultConfig.WeaponProfiles
	)
	for _, key in ipairs({
		"WeaponOrder",
		"ModeOrder",
		"Weapons",
		"Modes",
	}) do
		restored.AimAssistant[key] = Persistence.DeepCopy(
			Persistence.DefaultConfig.AimAssistant[key]
		)
	end

	local keepAimEnabled = Config.AimEnabled == true
		or State.AimActivationIntent == true

	for key in pairs(Config) do
		Config[key] = nil
	end

	for key, value in pairs(restored) do
		Config[key] = value
	end

	-- Loading or resetting settings may enable AIM, but it can never disable an
	-- already active AIM session. Only the dedicated AIM buttons can do that.
	Config.AimEnabled = keepAimEnabled or Config.AimEnabled == true
	State.AimActivationIntent = Config.AimEnabled == true

	Persistence.NormalizeConfig()

	return true
end

function Persistence.Reset()
	return Persistence.Apply(Persistence.DefaultConfig)
end

function Persistence.Save(rawName, overwrite)
	local name, message = Persistence.SafeName(rawName)
	if not name then return false, message end
	if overwrite ~= true and (State.SessionConfigurations[name] ~= nil
		or Persistence.DiskPathExists(Persistence.Path(name))) then
		return false, "Já existe uma configuração com esse nome. Toque em Salvar de novo para substituir.", "EXISTS"
	end

	local savedConfig = Persistence.DeepCopy(Config)

	-- Internal preset definitions are rebuilt from the script on load. Leaving
	-- them out keeps files smaller and prevents configuration/code drift.
	savedConfig.WeaponProfiles = nil
	if type(savedConfig.AimAssistant) == "table" then
		savedConfig.AimAssistant.WeaponOrder = nil
		savedConfig.AimAssistant.ModeOrder = nil
		savedConfig.AimAssistant.Weapons = nil
		savedConfig.AimAssistant.Modes = nil
	end

	local payload = {
		Schema = Persistence.Schema,
		Name = name,
		SavedAt = os.time(),
		Config = savedConfig,
	}

	if Persistence.HasDiskStorage() then
		Persistence.EnsureFolder()
		local encodedOk, encoded = pcall(function()
			return S.HttpService:JSONEncode(payload)
		end)

		if not encodedOk then
			return false, "Não consegui preparar esta configuração."
		end

		local writeOk, writeResult = pcall(function()
			return writefile(Persistence.Path(name), encoded)
		end)

		if not writeOk or writeResult == false then
			return false, "Não consegui salvar neste executor."
		end
	end

	State.SessionConfigurations[name] = Persistence.DeepCopy(payload)

	return true, name
end

function Persistence.Load(rawName)
	local name = Persistence.SafeName(rawName)
	if not name then
		return false, "Escolha uma configuração válida."
	end
	local payload = State.SessionConfigurations[name]
	local path = Persistence.Path(name)
	if Persistence.HasDiskStorage() then
		local exists = Persistence.DiskPathExists(path)
		if type(isfile) == "function" then
			local checked, result = pcall(isfile, path)
			if not checked then return false, "Não consegui acessar as configurações salvas." end
			exists = result == true
		end
		if exists then
			local readOk, content = pcall(readfile, path)
			if not readOk or type(content) ~= "string" then
				return false, "Não consegui ler essa configuração."
			end
			local valid, message = Persistence.ValidateJSONText(content)
			if not valid then return false, message end
			local decodeOk, decoded = pcall(function()
				return S.HttpService:JSONDecode(content)
			end)
			if not decodeOk or type(decoded) ~= "table" then
				return false, "O arquivo está danificado. Suas opções atuais foram mantidas."
			end
			payload = decoded
		end
	end
	if type(payload) ~= "table" then
		return false, "Não encontrei essa configuração."
	end
	local valid, source = Persistence.ValidatePayload(payload)
	if not valid then return false, source end
	local sanitized = Persistence.SanitizeTable(Persistence.DefaultConfig, source, nil)
	local ok, message = Persistence.Apply(sanitized)
	if not ok then return false, message end
	-- Cache only validated settings, and only after a successful application.
	State.SessionConfigurations[name] = {
		Schema = Persistence.Schema, Name = name, Config = Persistence.DeepCopy(Config),
	}
	return true, name
end

function Persistence.Delete(rawName)
	local name = Persistence.SafeName(rawName)
	if not name then
		return false, "Escolha uma configuração válida."
	end

	local sessionExisted = State.SessionConfigurations[name] ~= nil
	local path = Persistence.Path(name)
	local diskExists = Persistence.DiskPathExists(path)

	if diskExists then
		if type(delfile) ~= "function" then
			return false, "Este executor não permite excluir arquivos salvos."
		end

		local deleted, deleteResult = pcall(delfile, path)
		if not deleted or deleteResult == false then
			return false, "Não consegui excluir essa configuração."
		end
	end

	State.SessionConfigurations[name] = nil
	local existed = sessionExisted or diskExists
	return existed, existed and name or "Não encontrei essa configuração."
end

function Persistence.List()
	local names = {}
	local found = {}

	for name in pairs(State.SessionConfigurations) do
		found[name] = true
	end

	if type(listfiles) == "function" then
		Persistence.EnsureFolder()
		local ok, files = pcall(listfiles, Persistence.Folder)

		if ok and type(files) == "table" then
			for _, path in ipairs(files) do
				local fileName = tostring(path):match("([^/\\]+)%.json$")
				local safe = Persistence.SafeName(fileName)
				if safe then
					found[safe] = true
				end
			end
		end
	end

	for name in pairs(found) do
		names[#names + 1] = name
	end

	table.sort(names, function(a, b)
		return string.lower(a) < string.lower(b)
	end)

	return names
end

-- Tracks only connections that outlive GUI instances. Connections owned by a
-- button/label are released automatically when that GUI object is destroyed.
local Runtime = {
	Alive = true,
	Cleaned = false,
	Connections = {},
	RenderStepName = "AimAssistProV32_Render",
	ActiveRenderPriority = nil,
}

function Runtime.Track(connection)
	if connection then
		Runtime.Connections[#Runtime.Connections + 1] = connection
	end

	return connection
end

function Runtime.Disconnect(connection)
	if not connection then
		return
	end

	pcall(function()
		connection:Disconnect()
	end)
end

function Runtime.Untrack(connection)
	if not connection then
		return nil
	end

	for index = #Runtime.Connections, 1, -1 do
		if Runtime.Connections[index] == connection then
			table.remove(Runtime.Connections, index)
			break
		end
	end

	Runtime.Disconnect(connection)
	return nil
end

function Runtime.GetRenderPriority()
	return Config.LateRenderCorrection
		and Enum.RenderPriority.Last.Value - 2
		or Enum.RenderPriority.Camera.Value + 5
end

--==============================================================
-- COMMON HELPERS
--==============================================================

local Util = {}

Util.ThemeColorKeys = {
	"CardActive",
	"Accent",
	"Accent2",
	"AccentHot",
	"AccentSoft",
	"AccentDeep",
}

function Util.ThemeKeyForColor(color)
	if typeof(color) ~= "Color3" then
		return nil
	end

	for _, key in ipairs(Util.ThemeColorKeys) do
		if Theme[key] == color then
			return key
		end
	end

	return nil
end

-- Keep native pixel measurements predictable across mobile executors while
-- scaling menu typography from one shared point. World-space labels are not
-- affected by this interface-only scale.
local MENU_TEXT_SCALE = 1.10
local MENU_TEXT_MIN = 7
local MENU_TEXT_MAX = 16
local MENU_CORNER_MIN = 10

local function isMenuText(className, parent)
	if className ~= "TextLabel"
		and className ~= "TextButton"
		and className ~= "TextBox" then
		return false
	end

	local root = State.UI.Root
	return root ~= nil
		and parent ~= nil
		and (parent == root or parent:IsDescendantOf(root))
end

function Util.New(className, props, parent)
	local obj = Instance.new(className)
	local menuText = isMenuText(className, parent)

	for k, v in pairs(props or {}) do
		if menuText and k == "TextSize" and type(v) == "number" then
			v = math.clamp(
				math.floor(v * MENU_TEXT_SCALE + 0.5),
				MENU_TEXT_MIN,
				MENU_TEXT_MAX
			)
		end
		obj[k] = v

		local themeKey = Util.ThemeKeyForColor(v)
		if themeKey then
			obj:SetAttribute(
				"AAPTheme_" .. tostring(k),
				themeKey
			)
		end
	end

	if parent then
		obj.Parent = parent
	end

	return obj
end

function Util.Corner(obj, radius)
	local adjustedRadius = radius
	local root = State.UI.Root

	if root
		and obj
		and radius < 999
		and (obj == root or obj:IsDescendantOf(root)) then

		adjustedRadius = math.max(radius, MENU_CORNER_MIN)
	end

	return Util.New("UICorner", {
		CornerRadius = UDim.new(0, adjustedRadius),
	}, obj)
end

function Util.FitText(label, minimum, maximum)
	if not label then
		return label
	end

	label.TextScaled = true
	Util.New("UITextSizeConstraint", {
		MinTextSize = minimum or 6,
		MaxTextSize = maximum or 10,
	}, label)

	return label
end

function Util.Stroke(obj, color, transparency, thickness)
	return Util.New("UIStroke", {
		Color = color or Theme.Border,
		Transparency = transparency or 0,
		Thickness = thickness or 1,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
		LineJoinMode = Enum.LineJoinMode.Round,
	}, obj)
end

function Util.Gradient(obj, c1, c2, rotation)
	local gradient = Util.New("UIGradient", {
		Color = ColorSequence.new(c1, c2),
		Rotation = rotation or 0,
	}, obj)

	local key1 = Util.ThemeKeyForColor(c1)
	local key2 = Util.ThemeKeyForColor(c2)
	if key1 then
		gradient:SetAttribute("AAPTheme_C1", key1)
	end
	if key2 then
		gradient:SetAttribute("AAPTheme_C2", key2)
	end

	return gradient
end

function Util.GlassGradient(obj, c1, c2, topTransparency, bottomTransparency, rotation)
	local firstColor = c1 or Theme.GlassRaised
	local secondColor = c2 or Theme.Glass
	local gradient = Util.New("UIGradient", {
		Color = ColorSequence.new(
			firstColor,
			secondColor
		),
		Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, topTransparency or 0),
			NumberSequenceKeypoint.new(1, bottomTransparency or 0),
		}),
		Rotation = rotation or 90,
	}, obj)

	local key1 = Util.ThemeKeyForColor(firstColor)
	local key2 = Util.ThemeKeyForColor(secondColor)
	if key1 then
		gradient:SetAttribute("AAPTheme_C1", key1)
	end
	if key2 then
		gradient:SetAttribute("AAPTheme_C2", key2)
	end

	return gradient
end

function Util.Sheen(obj, transparency)
	return Util.New("UIGradient", {
		Color = ColorSequence.new(
			Color3.fromRGB(255, 255, 255),
			Color3.fromRGB(176, 181, 198)
		),
		Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, transparency or 0.02),
			NumberSequenceKeypoint.new(0.48, math.min((transparency or 0.02) + 0.08, 1)),
			NumberSequenceKeypoint.new(1, math.min((transparency or 0.02) + 0.20, 1)),
		}),
		Rotation = 90,
	}, obj)
end

function Util.InnerHighlight(obj, inset, transparency, zIndex)
	local line = Util.New("Frame", {
		Position = UDim2.fromOffset(inset or 10, 1),
		Size = UDim2.new(1, -((inset or 10) * 2), 0, 1),
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		BackgroundTransparency = transparency or 0.88,
		BorderSizePixel = 0,
		ZIndex = zIndex or (obj.ZIndex + 1),
	}, obj)
	Util.Corner(line, 999)
	return line
end

function Util.Tween(obj, props, duration)
	if not obj or not obj.Parent then
		return nil
	end

	local tween = S.TweenService:Create(
		obj,
		TweenInfo.new(
			duration or 0.14,
			Enum.EasingStyle.Quart,
			Enum.EasingDirection.Out
		),
		props
	)

	tween:Play()
	return tween
end

function Util.ClampCenteredAxis(value, halfSize, viewportSize, margin)
	margin = margin or 6

	local minimum = halfSize + margin
	local maximum = viewportSize - halfSize - margin

	-- If the object is larger than the viewport, centering is safer than
	-- calling math.clamp with an inverted range.
	if minimum > maximum then
		return viewportSize * 0.5
	end

	return math.clamp(value, minimum, maximum)
end

function Util.ClampAnchoredAxis(
	value,
	size,
	anchor,
	viewportSize,
	margin
)
	margin = margin or 6

	local minimum = size * anchor + margin
	local maximum =
		viewportSize
		- size * (1 - anchor)
		- margin

	-- Keep oversized objects centered while respecting their AnchorPoint.
	if minimum > maximum then
		return
			viewportSize * 0.5
			+ size * (anchor - 0.5)
	end

	return math.clamp(value, minimum, maximum)
end

local TEAM_IDENTITY_ATTRIBUTES = {
	"FactionId",
	"FactionID",
	"FactionName",
	"Faction",
	"faction",
	"SideId",
	"SideID",
	"SideName",
	"Side",
	"side",
	"TeamId",
	"TeamID",
	"TeamName",
	"Team",
	"team",
}

local TEAM_IDENTITY_ATTRIBUTE_SET = {}
for _, attributeName in ipairs(TEAM_IDENTITY_ATTRIBUTES) do
	TEAM_IDENTITY_ATTRIBUTE_SET[attributeName] = true
end

local TEAM_IDENTITY_CACHE = setmetatable({}, {__mode = "k"})

function Util.NormalizeTeamIdentityValue(value)
	local valueType = typeof(value)
	if valueType ~= "string"
		and valueType ~= "number"
		and valueType ~= "boolean" then

		return nil, nil
	end

	local label = tostring(value)
		:gsub("[%c]", " ")
		:gsub("^%s+", "")
		:gsub("%s+$", "")
		:gsub("%s+", " ")

	if label == "" then
		return nil, nil
	end

	label = label:sub(1, 64)
	return string.lower(label), label
end

function Util.TeamAttributeIdentity(player, attributeName)
	if not player then
		return nil, nil
	end

	local value = player:GetAttribute(attributeName)
	local character = player.Character

	if value == nil and character then
		value = character:GetAttribute(attributeName)
	end

	return Util.NormalizeTeamIdentityValue(value)
end

function Util.CustomTeamIdentity(player)
	if not player then
		return nil, nil, nil
	end

	local character = player.Character
	local cached = TEAM_IDENTITY_CACHE[player]
	if cached and cached.Character == character then
		return cached.Token, cached.Label, cached.Attribute
	end

	for _, attributeName in ipairs(TEAM_IDENTITY_ATTRIBUTES) do
		local token, label = Util.TeamAttributeIdentity(
			player,
			attributeName
		)

		if token then
			TEAM_IDENTITY_CACHE[player] = {
				Character = character,
				Token = token,
				Label = label,
				Attribute = attributeName,
			}
			return token, label, attributeName
		end
	end

	TEAM_IDENTITY_CACHE[player] = {
		Character = character,
		Token = nil,
		Label = nil,
		Attribute = nil,
	}
	return nil, nil, nil
end

function Util.InvalidateAllTeamIdentities()
	for player in pairs(TEAM_IDENTITY_CACHE) do
		TEAM_IDENTITY_CACHE[player] = nil
	end
end

function Util.TeamName(player)
	if player and player.Team then
		return player.Team.Name
	end

	local _, label = Util.CustomTeamIdentity(player)
	return label or "Sem equipe"
end

function Util.Relation(player)
	if player == S.LocalPlayer then
		return "SELF"
	end

	if not player then
		return "NEUTRAL"
	end

	if State.ManualAllies[player] then
		return "ALLY"
	end

	return "ENEMY"
end

function Util.RelationLabel(player)
	if player and State.ManualAllies[player] then
		return "Protegido"
	end

	local relation =
		Util.Relation(player)

	if relation == "ENEMY" then
		return "Outro jogador"
	elseif relation == "ALLY" then
		return "Aliado"
	elseif relation == "SELF" then
		return "Você"
	end

	return "Neutro"
end

function Util.TeamColor(player)
	if Config.ESPUseTeamColors
		and player
		and player.Team then

		return player.Team.TeamColor.Color
	end

	return RelationColors[
		Util.Relation(player)
	] or RelationColors.NEUTRAL
end

function Util.LocalCharacterAlive()
	local character = S.LocalPlayer.Character

	if not character
		or not character.Parent
		or not character:IsDescendantOf(S.Workspace) then

		return false
	end

	local humanoid = character:FindFirstChildOfClass("Humanoid")

	return not humanoid or humanoid.Health > 0
end

local Universal = {}

function Universal.IsTeamAttribute(attributeName)
	return TEAM_IDENTITY_ATTRIBUTE_SET[attributeName] == true
end

function Universal.ESPRelationAllowed(player)
	local relation =
		Util.Relation(player)

	if relation == "ENEMY" then
		return Config.ESPEnemies
	elseif relation == "ALLY" then
		return Config.ESPAllies
	end

	return false
end

--==============================================================
-- PLAYER CACHE
--==============================================================

local PlayerCache = {}

local ExactRegionByPartName = {}

for regionName, regionInfo in pairs(
	BodyRegions
) do
	for _, partName in ipairs(
		regionInfo.Parts
	) do
		ExactRegionByPartName[
			string.lower(partName)
		] = regionName
	end
end

function PlayerCache.Get(player)
	local record =
		State.Records[player]

	if record then
		return record
	end

	record = {
		Player = player,
		Character = nil,
		Humanoid = nil,
		Head = nil,
		Torso = nil,
		Root = nil,
		BodyParts = {},
		Highlight = nil,
		SelectedHighlight = nil,
		Label = nil,
		LabelText = nil,
		DisplayDistance = nil,
		LastLabelText = nil,
		Connections = {},
		CharacterConnections = {},
		HumanoidHealthConnection = nil,
		LifecycleHumanoid = nil,
		OnPartsRefreshed = nil,
		LastAlive = nil,
		PartRefreshPending = false,
		PartRefreshGeneration = 0,
	}

	State.Records[player] = record

	return record
end

function PlayerCache.ClearCharacterConnections(record)
	for _, connection in ipairs(
		record.CharacterConnections or {}
	) do
		Runtime.Disconnect(connection)
	end

	record.CharacterConnections = {}
	Runtime.Disconnect(record.HumanoidHealthConnection)
	record.HumanoidHealthConnection = nil
	record.LifecycleHumanoid = nil
	record.OnPartsRefreshed = nil
	record.LastAlive = nil
	record.PartRefreshPending = false
	record.PartRefreshGeneration =
		(record.PartRefreshGeneration or 0) + 1
end

function PlayerCache.ClassifyPart(part)
	if not part:IsA("BasePart") then
		return nil
	end

	if part:FindFirstAncestorOfClass("Accessory")
		or part:FindFirstAncestorOfClass("Tool") then

		return nil
	end

	local raw =
		string.lower(part.Name)

	local exact =
		ExactRegionByPartName[raw]

	if exact then
		return exact
	end

	local compact =
		raw:gsub("[%s_%-]", "")

	if compact:find("head", 1, true)
		or compact:find("skull", 1, true) then

		return "Head"
	end

	if compact:find("torso", 1, true)
		or compact:find("chest", 1, true)
		or compact:find("body", 1, true)
		or compact:find("spine", 1, true)
		or compact:find("core", 1, true) then

		return "Torso"
	end

	local left =
		compact:find("left", 1, true) ~= nil

	local right =
		compact:find("right", 1, true) ~= nil

	local arm =
		compact:find("arm", 1, true)
		or compact:find("hand", 1, true)
		or compact:find("shoulder", 1, true)
		or compact:find("forearm", 1, true)
		or compact:find("wrist", 1, true)

	local leg =
		compact:find("leg", 1, true)
		or compact:find("foot", 1, true)
		or compact:find("thigh", 1, true)
		or compact:find("calf", 1, true)
		or compact:find("shin", 1, true)
		or compact:find("ankle", 1, true)

	if left and arm then
		return "LeftArm"
	elseif right and arm then
		return "RightArm"
	elseif left and leg then
		return "LeftLeg"
	elseif right and leg then
		return "RightLeg"
	end

	return nil
end

function PlayerCache.RefreshBodyParts(record)
	local character =
		record.Character

	if not character
		or not character.Parent then

		return
	end

	local descendants =
		character:GetDescendants()

	local function usablePart(part)
		return part
			and part:IsA("BasePart")
			and part:IsDescendantOf(character)
			and not part:FindFirstAncestorOfClass("Accessory")
			and not part:FindFirstAncestorOfClass("Tool")
	end

	local partsByName = {}
	for _, item in ipairs(descendants) do
		if usablePart(item) and not partsByName[item.Name] then
			partsByName[item.Name] = item
		end
	end

	local function findBodyPart(name)
		local direct = character:FindFirstChild(name)

		if usablePart(direct) then
			return direct
		end

		return partsByName[name]
	end

	record.Humanoid =
		character:FindFirstChildOfClass("Humanoid")
		or character:FindFirstChildWhichIsA("Humanoid", true)

	local humanoidRoot =
		record.Humanoid
		and record.Humanoid.RootPart

	record.Root =
		(usablePart(humanoidRoot) and humanoidRoot)
		or findBodyPart("HumanoidRootPart")
		or findBodyPart("UpperTorso")
		or findBodyPart("Torso")
		or (
			usablePart(character.PrimaryPart)
			and character.PrimaryPart
		)

	record.Head =
		findBodyPart("Head")

	record.Torso =
		findBodyPart("UpperTorso")
		or findBodyPart("Torso")
		or findBodyPart("LowerTorso")

	record.BodyParts = {}

	local seen = {}

	for _, regionName in ipairs(
		BodyRegionOrder
	) do
		record.BodyParts[regionName] = {}
		seen[regionName] = {}
	end

	local function addPart(regionName, part)
		if not regionName
			or not usablePart(part)
			or seen[regionName][part] then

			return
		end

		seen[regionName][part] = true

		record.BodyParts[regionName][
			#record.BodyParts[regionName] + 1
		] = part
	end

	-- Exact canonical names first.
	for regionName, regionInfo in pairs(
		BodyRegions
	) do
		for _, partName in ipairs(
			regionInfo.Parts
		) do
			local part =
				findBodyPart(partName)

			addPart(
				regionName,
				part
			)
		end
	end

	-- Then classify custom rig part names heuristically.
	for _, item in ipairs(descendants) do
		if item:IsA("BasePart") then
			local region =
				PlayerCache.ClassifyPart(
					item
				)

			addPart(
				region,
				item
			)

			if not record.Root
				and usablePart(item) then

				record.Root = item
			end
		end
	end

	-- Practical fallbacks for unusual player rigs.
	if not record.Head then
		record.Head =
			record.BodyParts.Head[1]
			or record.Root
	end

	if not record.Torso then
		record.Torso =
			record.BodyParts.Torso[1]
			or record.Root
	end

	if record.Root
		and #record.BodyParts.Torso == 0 then

		addPart(
			"Torso",
			record.Root
		)
	end

	if record.Head
		and #record.BodyParts.Head == 0 then

		addPart(
			"Head",
			record.Head
		)
	end
end

function PlayerCache.SchedulePartRefresh(record)
	if record.PartRefreshPending then
		return
	end

	record.PartRefreshPending = true
	local character = record.Character
	local generation = record.PartRefreshGeneration

	task.defer(function()
		if record.PartRefreshGeneration ~= generation then
			return
		end

		record.PartRefreshPending = false

		if Runtime.Alive
			and record.Character == character
			and character
			and character.Parent then

			PlayerCache.RefreshBodyParts(
				record
			)

			if record.OnPartsRefreshed then
				record.OnPartsRefreshed(character)
			end
		end
	end)
end

function PlayerCache.BindCharacter(player, character)
	local record =
		PlayerCache.Get(player)

	PlayerCache.ClearCharacterConnections(
		record
	)

	if not character or not character:IsA("Model") then
		record.Character = nil
		record.Humanoid = nil
		record.Head = nil
		record.Torso = nil
		record.Root = nil
		record.BodyParts = {}
		return record
	end

	record.Character = character
	record.LastAlive = nil

	PlayerCache.RefreshBodyParts(
		record
	)

	local added =
		character.DescendantAdded:
		Connect(function(item)
			if item:IsA("BasePart") or item:IsA("Humanoid") then
				PlayerCache.SchedulePartRefresh(record)
			end
		end)

	local removing =
		character.DescendantRemoving:
		Connect(function(item)
			if item:IsA("BasePart") or item:IsA("Humanoid") then
				PlayerCache.SchedulePartRefresh(record)
			end
		end)

	local ancestry =
		character.AncestryChanged:
		Connect(function(_, parent)
			if not parent then
				PlayerCache.ClearCharacterConnections(
					record
				)
			end
		end)

	record.CharacterConnections = {
		added,
		removing,
		ancestry,
	}

	return record
end

function PlayerCache.PartBelongsToRecord(record, part)
	return record
		and record.Character
		and record.Character.Parent
		and record.Character:IsDescendantOf(S.Workspace)
		and part
		and part:IsA("BasePart")
		and part:IsDescendantOf(record.Character)
end

function PlayerCache.ClearCharacter(record)
	if not record then
		return
	end

	PlayerCache.ClearCharacterConnections(record)
	record.Character = nil
	record.Humanoid = nil
	record.Head = nil
	record.Torso = nil
	record.Root = nil
	record.BodyParts = {}
	record.LastAlive = nil
end

function PlayerCache.IsAlive(record)
	if not record
		or not record.Character
		or not record.Character.Parent
		or not record.Character:IsDescendantOf(S.Workspace) then

		return false
	end

	if record.Humanoid
		and record.Humanoid.Parent
		and record.Humanoid:IsDescendantOf(record.Character) then

		return record.Humanoid.Health > 0
	end

	-- Custom player rigs without a Humanoid can still be tracked
	-- as long as they expose at least one BasePart/root.
	return record.Root
		and PlayerCache.PartBelongsToRecord(
			record,
			record.Root
		)
end

function PlayerCache.Disconnect(player)
	local record =
		State.Records[player]

	if not record then
		return
	end

	for _, connection in ipairs(
		record.Connections
	) do
		Runtime.Disconnect(connection)
	end

	record.Connections = {}

	PlayerCache.ClearCharacterConnections(
		record
	)
end

--==============================================================
-- ESP
--==============================================================

local ESP = {}

function ESP.ColorFor(player)
	if Config.ESPUseTeamColors then
		return Util.TeamColor(player)
	end

	return Theme.Accent
end

function ESP.ShouldShow(player)
	if player == S.LocalPlayer then
		return false
	end

	if not Config.ESPEnabled then
		return false
	end

	if Config.GlobalESP then
		return true
	end

	return Universal.ESPRelationAllowed(
		player
	)
end

function ESP.ClearLabel(record)
	if not record then
		return
	end

	if record.Label then
		record.Label:Destroy()
	end

	record.Label = nil
	record.LabelText = nil
	record.DisplayDistance = nil
	record.LastLabelText = nil
end

function ESP.Clear(record)
	if not record then
		return
	end

	if record.Highlight then
		record.Highlight:Destroy()
		record.Highlight = nil
	end

	if record.SelectedHighlight then
		record.SelectedHighlight:Destroy()
		record.SelectedHighlight = nil
	end


	ESP.ClearLabel(record)
end

function ESP.EnsureNormal(record)
	local player = record.Player

	if player == S.LocalPlayer then
		return
	end

	if not ESP.ShouldShow(player) then
		if record.Highlight then
			record.Highlight:Destroy()
			record.Highlight = nil
		end

		return
	end

	if not record.Character or not record.Character.Parent then
		return
	end

	if not record.Highlight or not record.Highlight.Parent then
		record.Highlight = Util.New("Highlight", {
			Name = "AAP_Team",
			DepthMode = Enum.HighlightDepthMode.AlwaysOnTop,
			FillTransparency = 0.86,
			OutlineTransparency = 0.04,
		}, record.Character)
	end

	local color = ESP.ColorFor(player)

	record.Highlight.Adornee = record.Character
	record.Highlight.FillColor = color
	record.Highlight.OutlineColor = color
	record.Highlight.Enabled = true
end

function ESP.EnsureSelected(record)
	local player = record.Player
	local enabled =
		Config.ESPEnabled
		and Config.SelectedESP
		and State.SelectedPlayers[player]

	if not enabled then
		if record.SelectedHighlight then
			record.SelectedHighlight:Destroy()
			record.SelectedHighlight = nil
		end

		return
	end

	if not record.Character or not record.Character.Parent then
		return
	end

	if not record.SelectedHighlight or not record.SelectedHighlight.Parent then
		record.SelectedHighlight = Util.New("Highlight", {
			Name = "AAP_Selected",
			DepthMode = Enum.HighlightDepthMode.AlwaysOnTop,
			FillTransparency = 0.88,
			OutlineTransparency = 0,
			FillColor = Theme.AccentSoft,
			OutlineColor = Theme.Accent2,
		}, record.Character)
	end

	record.SelectedHighlight.Adornee = record.Character
	record.SelectedHighlight.FillColor = Theme.AccentSoft
	record.SelectedHighlight.OutlineColor = Theme.Accent2
	record.SelectedHighlight.Enabled = true
end

function ESP.UpdateLabel(record)
	if not record
		or not record.LabelText
		or not record.LabelText.Parent then

		return
	end

	local player = record.Player
	local anchor =
		(
			PlayerCache.PartBelongsToRecord(
				record,
				record.Root
			)
			and record.Root
		)
		or (
			PlayerCache.PartBelongsToRecord(
				record,
				record.Head
			)
			and record.Head
		)

	local distanceText = "-- studs"

	if S.Camera and anchor then
		local targetDistance = math.floor(
			(
				anchor.Position
					- S.Camera.CFrame.Position
			).Magnitude + 0.5
		)

		local now = os.clock()
		local elapsed = math.clamp(now - (record.DistanceUpdatedAt or now), 0, 1)
		record.DistanceUpdatedAt = now
		local displayDistance = record.DisplayDistance
		local maximumStep = math.max(1, math.ceil(60 * elapsed))
		if displayDistance == nil or math.abs(targetDistance - displayDistance) > 12 then
			displayDistance = targetDistance
		else
			displayDistance += math.clamp(targetDistance - displayDistance, -maximumStep, maximumStep)
		end

		record.DisplayDistance = displayDistance

		distanceText =
			tostring(displayDistance)
			.. " studs"
	end

	local nextText =
		string.format(
			"%s | %s | %s | %s",
			player.DisplayName,
			Util.TeamName(player),
			Util.RelationLabel(player),
			distanceText
		)

	if record.LastLabelText ~= nextText then
		record.LastLabelText = nextText
		record.LabelText.Text = nextText
	end
end

function ESP.EnsureLabel(record)
	local player = record.Player

	local enabled =
		Config.ESPEnabled
		and Config.ESPLabels
		and (
			ESP.ShouldShow(player)
			or (
				Config.SelectedESP
				and State.SelectedPlayers[player]
			)
		)

	if not enabled then
		ESP.ClearLabel(record)
		return
	end

	if not record.Character or not record.Character.Parent then
		return
	end

	local adornee =
		PlayerCache.PartBelongsToRecord(record, record.Head)
		and record.Head
		or (
			PlayerCache.PartBelongsToRecord(record, record.Root)
			and record.Root
		)

	if not adornee then
		ESP.ClearLabel(record)
		return
	end

	if not record.Label or not record.Label.Parent then
		record.DisplayDistance = nil
		record.LastLabelText = nil
		record.Label = Util.New("BillboardGui", {
			Name = "AAP_Label",
			AlwaysOnTop = true,
			Size = UDim2.fromOffset(210, 18),
			StudsOffset = Vector3.new(0, 2.35, 0),
			MaxDistance = 0,
			Adornee = adornee,
		}, record.Character)

	end

	if not record.LabelText
		or record.LabelText.Parent ~= record.Label then

		record.LastLabelText = nil

		record.LabelText = Util.New("TextLabel", {
			Name = "AAP_LabelText",
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 1,
			Text = "",
			TextColor3 = ESP.ColorFor(player),
			TextStrokeTransparency = 0.52,
			TextStrokeColor3 = Color3.new(0, 0, 0),
			Font = Enum.Font.GothamMedium,
			TextSize = 8,
			TextScaled = false,
			TextWrapped = false,
		}, record.Label)
	end

	record.Label.Adornee = adornee
	record.LabelText.TextColor3 =
		State.SelectedPlayers[player]
		and Theme.Accent2
		or ESP.ColorFor(player)

	ESP.UpdateLabel(record)
end

function ESP.Refresh(player)
	if player == S.LocalPlayer then
		return
	end

	local record = PlayerCache.Get(player)

	if player.Parent ~= S.Players then
		ESP.Clear(record)
		return
	end

	-- Jogador morto ou sem personagem: remove tudo imediatamente.
	-- Isso evita o ESP reaparecer no corpo morto por outro evento.
	if not PlayerCache.IsAlive(record) then
		ESP.Clear(record)
		return
	end

	ESP.EnsureNormal(record)
	ESP.EnsureSelected(record)
	ESP.EnsureLabel(record)
end

function ESP.SafeRefresh(player)
	local ok, refreshError = pcall(ESP.Refresh, player)

	if ok then
		return true
	end

	State.ESPRecoveries += 1
	State.LastRuntimeError = string.sub(
		tostring(refreshError),
		1,
		240
	)

	local record = State.Records[player]
	if record then
		pcall(ESP.Clear, record)
	end

	return false
end

function ESP.RefreshAll()
	for _, player in ipairs(S.Players:GetPlayers()) do
		if player ~= S.LocalPlayer then
			ESP.SafeRefresh(player)
		end
	end
end

--==============================================================
-- AIM ENGINE
--==============================================================

local Aim = {}
local TargetSwipe = {}

Aim.RayParams = RaycastParams.new()
Aim.RayParams.FilterType = Enum.RaycastFilterType.Exclude
Aim.RayParams.IgnoreWater = true

function Aim.GetProfile()
	-- Assistant presets already write the final weapon-adjusted values into
	-- Config. Keep the profile multiplier neutral while a preset is active.
	if Config.AimAssistant
		and Config.AimAssistant.Applied then

		return Config.WeaponProfiles.DEFAULT
	end

	return Config.WeaponProfiles[Config.WeaponProfile]
		or Config.WeaponProfiles.DEFAULT
end

function Aim.EffectiveFOV()
	local profile = Aim.GetProfile()
	return Config.FOV * (profile.FOVScale or 1)
end

function Aim.IsExplicitlySelected(player)
	return Config.AimMode == "SELECTED"
		and State.SelectedPlayers[player] == true
end

function Aim.FOVAllows(player, screenDistance, multiplier)
	if Aim.IsExplicitlySelected(player) then
		return true
	end

	return not Config.FOVEnabled
		or screenDistance
			<= Aim.EffectiveFOV()
				* (multiplier or 1)
end

function Aim.EffectiveStrength()
	local profile = Aim.GetProfile()

	return math.clamp(
		Config.AimStrength
		*
		((profile.Strength or 100) / 100),
		0,
		100
	)
end

function Aim.EffectiveSmoothing()
	local profile = Aim.GetProfile()

	return math.clamp(
		Config.Smoothing
		+
		(profile.Smoothing or 0),
		0,
		100
	)
end

function Aim.EffectivePredictionScale()
	local profile = Aim.GetProfile()
	return profile.PredictionScale or 1
end

function Aim.PlayerAllowed(player)
	if State.ManualAllies[player] then
		return false
	end

	return player ~= nil and player ~= S.LocalPlayer
end

function Aim.RegionEnabled(regionName)
	return Config.BodyRegionEnabled[regionName] == true
end

function Aim.RegionWeight(regionName)
	return math.clamp(
		Config.BodyRegionWeights[regionName] or 0,
		0,
		100
	)
end

function Aim.PointVisible(record, point, forceCheck)
	if not forceCheck and not Config.WallCheck then
		return true
	end

	if not S.Camera
		or not record
		or not record.Character
		or not record.Character.Parent then
		return false
	end

	local ownCharacter = S.LocalPlayer.Character

	if not ownCharacter or not Util.LocalCharacterAlive() then
		return false
	end

	local origin =
		S.Camera.CFrame.Position

	local direction =
		point - origin

	if direction.Magnitude <= 0.001 then
		return true
	end

	local ignored = {
		ownCharacter,
	}

	-- First-person viewmodels are commonly parented to CurrentCamera and
	-- should never be mistaken for a wall in front of the local player.
	ignored[#ignored + 1] = S.Camera

	-- Always perform the first raycast. The configured value is the number of
	-- fully transparent, non-collidable pieces that may be skipped afterward.
	local raycastAttempts = math.max(
		math.floor(
			Persistence.FiniteNumber(Config.WallPassthroughLimit, 0)
		) + 1,
		1
	)

	for _ = 1, raycastAttempts do
		Aim.RayParams.FilterDescendantsInstances =
			ignored

		local result =
			S.Workspace:Raycast(
				origin,
				direction,
				Aim.RayParams
			)

		if not result then
			return true
		end

		local hit = result.Instance

		if hit
			and hit:IsDescendantOf(
				record.Character
			) then

			return true
		end

		if hit
			and hit:IsA("BasePart")
			and hit.Transparency >= 0.98
			and not hit.CanCollide then

			ignored[#ignored + 1] = hit
		else
			return false
		end
	end

	return false
end

function Aim.CurrentPointVisible()
	if not State.CurrentTarget
		or not State.CurrentPart
		or not State.CurrentPart.Parent then

		return false
	end

	local record =
		State.Records[State.CurrentTarget]

	if not record then
		return false
	end

	local point =
		Aim.CurrentAimPoint()

	if not point then
		return false
	end

	return Aim.PointVisible(
		record,
		point
	)
end

function Aim.ClearCurrentTarget(reason)
	TargetSwipe.CancelTransition()

	State.CurrentTarget = nil
	State.CurrentPart = nil
	State.CurrentRegion = nil
	State.CurrentLocalOffset = nil
	State.Debug.LastScore = nil
	State.Debug.LastRegion = nil
	State.Debug.LastDistance = nil

	if reason then
		State.Debug.LastReason =
			reason
	end
end

function Aim.MarkAssistantCustomized()
	local assistant = Config.AimAssistant
	if not assistant or not assistant.Applied then
		return
	end

	assistant.Customized = true
	State.ActiveQuickPresetKey = nil

	if State.UI.RefreshQuickPresetVisuals then
		State.UI.RefreshQuickPresetVisuals()
	end

	local profileLabel = State.UI.CurrentProfileLabel
	if profileLabel and profileLabel.Parent then
		profileLabel.Text = "PERSONALIZADO"
	end
end

function Aim.ApplyAssistantPreset(weaponKey, modeKey)
	local assistant = Config.AimAssistant

	if not assistant then
		return false
	end

	local weapon = assistant.Weapons[weaponKey]
	local mode = assistant.Modes[modeKey]

	if not weapon or not mode then
		return false
	end

	local maximum = modeKey == "MAXIMUM"
	local function rounded(value)
		return math.floor(value + 0.5)
	end

	assistant.Weapon = weaponKey
	assistant.Mode = modeKey
	assistant.Applied = true
	assistant.Customized = false
	State.ActiveQuickPresetKey = nil

	Config.WeaponProfile = weapon.Profile
	Config.Accuracy = maximum
		and 100
		or math.clamp(
			rounded(mode.Accuracy + weapon.AccuracyOffset),
			10,
			100
		)

	Config.AimStrength = maximum
		and 100
		or math.clamp(
			rounded(mode.Strength + weapon.StrengthOffset),
			10,
			100
		)

	Config.Smoothing = maximum
		and 0
		or math.clamp(
			rounded(mode.Smoothing + weapon.SmoothingOffset),
			0,
			100
		)

	Config.HorizontalStrength = maximum
		and 100
		or math.clamp(
			rounded(mode.Horizontal + weapon.HorizontalOffset),
			0,
			100
		)

	Config.VerticalStrength = maximum
		and 100
		or math.clamp(
			rounded(mode.Vertical + weapon.VerticalOffset),
			0,
			100
		)

	Config.ResponseSpeed = math.clamp(
		rounded(mode.Response + weapon.ResponseOffset),
		12,
		80
	)

	Config.SmoothingCurve = "DYNAMIC"
	Config.SnapAtMaximum = maximum

	Config.Prediction = true
	Config.PredictionMode = "AUTO"
	Config.PredictionMin = weapon.PredictionMin
	Config.PredictionMax = weapon.PredictionMax
	Config.PredictionTime =
		(weapon.PredictionMin + weapon.PredictionMax)
		* 0.5

	Config.FOVEnabled = true
	Config.FOV = math.clamp(
		rounded(weapon.FOV * mode.FOVScale),
		50,
		1000
	)
	Config.RetentionFOVMultiplier = mode.Retention
	Config.OnScreenOnly = true

	Config.StickyTarget = true
	Config.StickyGrace = mode.StickyGrace
	Config.TargetSwitchPenalty = mode.SwitchPenalty
	Config.MaxBodyCandidates = mode.Candidates
	Config.TargetScanInterval = mode.ScanInterval

	Config.WallCheck = true
	Config.StrictWallCheck = true
	Config.RenderWallValidation = true
	Config.WallGrace = 0

	Config.DistanceCompensation = true
	Config.DistanceStrengthMin = mode.DistanceMin
	Config.DistanceStrengthMax = 1.00

	Config.StrictBodyRegion = true
	Config.BodyFallback = true
	Config.MultiPointBodyAim = true
	Config.ExactBodyAim = true
	Config.PreferPartCenter = true
	Config.PrimaryRegionBias = mode.PrimaryBias
	Config.CenterPointBias = mode.CenterBias
	Config.BodyAcquisitionPadding = weapon.BodyPadding

	Config.BodyRegionEnabled.Head = true
	Config.BodyRegionEnabled.Torso = true
	Config.BodyRegionEnabled.LeftArm = true
	Config.BodyRegionEnabled.RightArm = true
	Config.BodyRegionEnabled.LeftLeg = true
	Config.BodyRegionEnabled.RightLeg = true

	Config.BodyRegionWeights.Head =
		weapon.Primary == "Head"
		and 100
		or 88

	Config.BodyRegionWeights.Torso =
		weapon.Primary == "Torso"
		and 100
		or 86

	Config.BodyRegionWeights.LeftArm = 55
	Config.BodyRegionWeights.RightArm = 55
	Config.BodyRegionWeights.LeftLeg = 38
	Config.BodyRegionWeights.RightLeg = 38

	Config.HeadPredictionScale = weapon.HeadPredictionScale
	Config.LimbPredictionScale = weapon.LimbPredictionScale
	Config.ExactBodyPredictionBlend = mode.PredictionBlend
	Config.NearTargetPredictionBlend = mode.NearBlend
	Config.NearTargetRadius = maximum
		and 34
		or modeKey == "STRONG"
			and 38
			or modeKey == "BALANCED"
				and 44
				or 52

	Config.MicroCorrectionRadius = maximum
		and 16
		or modeKey == "STRONG"
			and 18
			or modeKey == "BALANCED"
				and 22
				or 28

	Config.MicroCorrectionBoost = mode.MicroBoost
	Config.CenterLockTolerance = mode.CenterTolerance

	Config.LongRangeCorrection = weapon.LongRange
	Config.LongRangeStart = weapon.LongRangeStart
	Config.LongRangeFull = weapon.LongRangeFull
	Config.LongRangeHeadLift = weapon.HeadLift
	Config.ScreenConvergence = true
	Config.ScreenConvergencePixels = mode.ScreenPixels
	Config.LateRenderCorrection = modeKey ~= "SOFT"

	-- Presets and manual priority changes use the same synchronization path.
	-- This keeps the 3D body selection and the MIRA priority label identical.
	if State.UI.SetPrimaryBodyRegion then
		State.UI.SetPrimaryBodyRegion(weapon.Primary, {
			MarkCustomized = false,
			ClearTarget = false,
		})
	end

	Aim.ClearCurrentTarget(
		"Perfil de mira aplicado"
	)

	return true
end

function Aim.ScreenDistance(point)
	if not S.Camera then
		return nil
	end

	local projected, onScreen =
		S.Camera:WorldToViewportPoint(point)

	if projected.Z <= 0 then
		return nil
	end

	if Config.OnScreenOnly and not onScreen then
		return nil
	end

	local viewport = S.Camera.ViewportSize
	local center = Vector2.new(
		viewport.X * 0.5,
		viewport.Y * 0.5
	)

	local p = Vector2.new(
		projected.X,
		projected.Y
	)

	return (p - center).Magnitude
end

function Aim.GetAimPoints(part, regionName, includeCenter)
	local points = {}

	if includeCenter ~= false then
		points[#points + 1] = {
			Position = part.Position,
			Bias = Config.CenterPointBias,
		}
	end

	if not Config.MultiPointBodyAim then
		return points
	end

	local sx = math.max(part.Size.X * 0.22, 0.04)
	local sy = math.max(part.Size.Y * 0.22, 0.04)

	if regionName == "Head" then
		sx = math.max(part.Size.X * 0.14, 0.03)
		sy = math.max(part.Size.Y * 0.14, 0.03)
	end

	points[#points + 1] = {
		Position = (part.CFrame * CFrame.new(sx, 0, 0)).Position,
		Bias = 12,
	}

	points[#points + 1] = {
		Position = (part.CFrame * CFrame.new(-sx, 0, 0)).Position,
		Bias = 12,
	}

	points[#points + 1] = {
		Position = (part.CFrame * CFrame.new(0, sy, 0)).Position,
		Bias = 8,
	}

	points[#points + 1] = {
		Position = (part.CFrame * CFrame.new(0, -sy, 0)).Position,
		Bias = 8,
	}

	return points
end

function Aim.RegionParts(record, regionName)
	local parts =
		record
		and record.BodyParts
		and record.BodyParts[regionName]
		or {}

	if regionName ~= Config.PrimaryBodyRegion
		or not Config.PrimaryBodyPartName then

		return parts
	end

	local exact = {}
	for _, part in ipairs(parts) do
		if part.Name == Config.PrimaryBodyPartName then
			exact[#exact + 1] = part
		end
	end

	-- Keep universal behavior: if a selected R15 segment does not exist on an
	-- R6 target (or vice versa), use the equivalent broad body region.
	return #exact > 0 and exact or parts
end

function Aim.PlayerAcquisitionDistance(record)
	local best = nil

	local function considerPart(part)
		if not PlayerCache.PartBelongsToRecord(record, part) then
			return
		end

		local distance = Aim.ScreenDistance(part.Position)

		if distance and (not best or distance < best) then
			best = distance
		end
	end

	local function considerRegion(regionName)
		for _, part in ipairs(
			Aim.RegionParts(record, regionName)
		) do
			considerPart(part)
		end
	end

	if Config.ExactBodyAim and Config.StrictBodyRegion then
		if Aim.RegionEnabled(Config.PrimaryBodyRegion) then
			considerRegion(Config.PrimaryBodyRegion)
		end

		if best
			and Aim.FOVAllows(
				record.Player,
				best,
				Config.BodyAcquisitionPadding
			) then

			return best
		end

		if not Config.BodyFallback then
			return best
		end
	end

	if Config.ExactBodyAim then
		for _, regionName in ipairs(BodyRegionOrder) do
			if Aim.RegionEnabled(regionName)
				and (
					not Config.StrictBodyRegion
					or regionName ~= Config.PrimaryBodyRegion
				) then

				considerRegion(regionName)
			end
		end
	end

	if not best then
		considerPart(record.Root)
		considerPart(record.Torso)
		considerPart(record.Head)
	end

	return best
end

function Aim.ResolveRegionPoint(record, regionName, ignoreFOV)
	if not Aim.RegionEnabled(regionName) then
		return nil
	end

	local best = nil
	local preferCenter = Config.ExactBodyAim
		and Config.PreferPartCenter
		and regionName == Config.PrimaryBodyRegion

	local function consider(part, point, bias, isCenter)
		local screenDistance = Aim.ScreenDistance(point)
		if ignoreFOV then
			-- A deliberate swipe may select a part outside the screen or FOV.
			-- Body selection, weights and wall checks still use the same rules.
			screenDistance = screenDistance or 0
		elseif not screenDistance
			or not Aim.FOVAllows(record.Player, screenDistance) then
			return
		end
		if not Aim.PointVisible(record, point) then
			return
		end

		local worldDistance = (point - S.Camera.CFrame.Position).Magnitude
		local score = screenDistance + math.min(worldDistance * 0.010, 24)
			+ (100 - Aim.RegionWeight(regionName)) * 0.55
			- (regionName == Config.PrimaryBodyRegion and Config.PrimaryRegionBias or 0)
			- (bias or 0)
		if not best or score < best.Score then
			best = {
				Part = part, Point = point, Region = regionName,
				Score = score, ScreenDistance = screenDistance,
				WorldDistance = worldDistance, IsCenter = isCenter,
				Visible = true,
			}
		end
	end

	for _, part in ipairs(Aim.RegionParts(record, regionName)) do
		if PlayerCache.PartBelongsToRecord(record, part) then
			if preferCenter then
				consider(part, part.Position, Config.CenterPointBias, true)
			end
			for _, aimPoint in ipairs(Aim.GetAimPoints(part, regionName, not preferCenter)) do
				consider(part, aimPoint.Position, aimPoint.Bias, false)
			end
		end
	end
	return best
end

function Aim.ResolveBestBodyPoint(record, ignoreFOV)
	if Config.StrictBodyRegion then
		local primary =
			Aim.ResolveRegionPoint(
				record,
				Config.PrimaryBodyRegion,
				ignoreFOV
			)

		if primary then
			return primary
		end

		if not Config.BodyFallback then
			return nil
		end
	end

	local best = nil

	for _, regionName in ipairs(BodyRegionOrder) do
		if Aim.RegionEnabled(regionName)
			and (
				not Config.StrictBodyRegion
				or regionName ~= Config.PrimaryBodyRegion
			) then

			local result =
				Aim.ResolveRegionPoint(
					record,
					regionName,
					ignoreFOV
				)

			if result
				and (
					not best
					or result.Score < best.Score
				) then

				best = result
			end
		end
	end

	return best
end

function Aim.CurrentAimPoint()
	if not State.CurrentPart
		or not State.CurrentPart.Parent then

		return nil
	end

	local record =
		State.CurrentTarget
		and State.Records[State.CurrentTarget]

	if not PlayerCache.PartBelongsToRecord(
		record,
		State.CurrentPart
	) then
		return nil
	end

	if State.CurrentLocalOffset then
		return State.CurrentPart.CFrame:
			PointToWorldSpace(
				State.CurrentLocalOffset
			)
	end

	return State.CurrentPart.Position
end

function Aim.CurrentTargetValid()
	if not State.CurrentTarget
		or State.CurrentTarget.Parent ~= S.Players
		or not State.CurrentPart
		or not State.CurrentPart.Parent then

		return false
	end

	local record =
		State.Records[State.CurrentTarget]

	if not record
		or not PlayerCache.IsAlive(record)
		or not PlayerCache.PartBelongsToRecord(
			record,
			State.CurrentPart
		) then

		return false
	end

	if not Aim.PlayerAllowed(State.CurrentTarget) then
		return false
	end

	if Config.AimMode == "SELECTED"
		and not State.SelectedPlayers[State.CurrentTarget] then

		return false
	end

	if not State.CurrentRegion
		or not Aim.RegionEnabled(State.CurrentRegion) then

		return false
	end

	if Config.StrictBodyRegion
		and State.CurrentRegion
		and State.CurrentRegion ~= Config.PrimaryBodyRegion then

		if not Config.BodyFallback then
			return false
		end

		-- Keep a valid fallback only while the preferred region is still
		-- unavailable. As soon as it becomes visible, force reacquisition.
		if Aim.ResolveRegionPoint(
			record,
			Config.PrimaryBodyRegion
		) then
			return false
		end
	end

	local point = Aim.CurrentAimPoint()

	if not point then
		return false
	end

	local screenDistance =
		Aim.ScreenDistance(point)
	local mobileOwnsTarget =
		Config.MobileFriendlySwitch == true
		and S.UIS.TouchEnabled == true

	-- The mobile gesture can deliberately select a player outside the normal
	-- FOV. Keep that player long enough for the camera to turn and lock onto it.
	if not screenDistance and not mobileOwnsTarget then
		return false
	end

	if not mobileOwnsTarget
		and not Aim.FOVAllows(
			State.CurrentTarget,
			screenDistance,
			Config.RetentionFOVMultiplier
		) then

		return false
	end

	if Aim.PointVisible(record, point) then
		State.LastTargetVisible =
			os.clock()
	else
		if Config.StrictWallCheck then
			return false
		end

		if (
			os.clock()
			-
			State.LastTargetVisible
		)
			> Config.WallGrace then

			return false
		end
	end

	return true
end

function Aim.CurrentTargetGraceValid()
	local player = State.CurrentTarget
	local record = player and State.Records[player]

	if not player
		or player.Parent ~= S.Players
		or not record
		or not PlayerCache.IsAlive(record)
		or not PlayerCache.PartBelongsToRecord(
			record,
			State.CurrentPart
		)
		or not Aim.PlayerAllowed(player)
		or not State.CurrentRegion
		or not Aim.RegionEnabled(State.CurrentRegion) then

		return false
	end

	if Config.AimMode == "SELECTED"
		and not State.SelectedPlayers[player] then

		return false
	end

	if Config.WallCheck and not Aim.CurrentPointVisible() then
		return false
	end

	return os.clock() - State.LastTargetSeen
		<= Config.StickyGrace
end

function Aim.PlayerCanBeTarget(record)
	local player = record.Player

	if player == S.LocalPlayer then
		return false
	end

	if not PlayerCache.IsAlive(record) then
		return false
	end

	if not Aim.PlayerAllowed(player) then
		return false
	end

	if Config.AimMode == "SELECTED"
		and not State.SelectedPlayers[player] then

		return false
	end

	return true
end


function Aim.AcquireTarget()
	State.Debug.Candidates = 0

	-- Keep a manually controlled target only while it can actually receive the
	-- aim. An invalid part, hidden player or incomplete character must never
	-- block the normal scanner just because gesture switching is enabled.
	if TargetSwipe.IsEnabled() then
		local retainedCandidate = TargetSwipe.RetainedCandidate()

		if retainedCandidate then
			State.Debug.LastReason =
				"Troca por gesto: alvo atual mantido"
			State.Debug.LastScore = nil
			State.Debug.LastRegion = retainedCandidate.Region
			State.Debug.LastDistance = S.Camera
				and (
					retainedCandidate.Point
					- S.Camera.CFrame.Position
				).Magnitude
				or nil

			return retainedCandidate
		end
	end

	if Config.StickyTarget and Aim.CurrentTargetValid() then
		local point = Aim.CurrentAimPoint()

		State.Debug.LastReason = "Alvo atual mantido"
		State.Debug.LastScore = nil
		State.Debug.LastRegion = State.CurrentRegion
		State.Debug.LastDistance =
			point
			and (point - S.Camera.CFrame.Position).Magnitude
			or nil

		return {
			Player = State.CurrentTarget,
			Record = State.Records[State.CurrentTarget],
			Part = State.CurrentPart,
			Region = State.CurrentRegion,
			Point = point,
			LocalOffset = State.CurrentLocalOffset,
			Score = -math.huge,
		}
	end

	local candidates = {}

	for _, player in ipairs(S.Players:GetPlayers()) do
		local record = State.Records[player]

		if record and Aim.PlayerCanBeTarget(record) then
			local centerDistance =
				Aim.PlayerAcquisitionDistance(record)

			if centerDistance then
				if Aim.FOVAllows(
					player,
					centerDistance,
					Config.BodyAcquisitionPadding
				) then
					State.Debug.Candidates += 1

					candidates[#candidates + 1] = {
						Record = record,
						Distance = centerDistance,
					}
				end
			end
		end
	end

	table.sort(
		candidates,
		function(a, b)
			if a.Distance == b.Distance then
				return a.Record.Player.UserId
					< b.Record.Player.UserId
			end

			return a.Distance < b.Distance
		end
	)

	local maxPlayers =
		math.min(
			#candidates,
			math.max(
				math.floor(Config.MaxBodyCandidates or 1),
				1
			)
		)

	local best = nil
	local index = 1

	while index <= #candidates do
		local record =
			candidates[index].Record

		local bodyResult =
			Aim.ResolveBestBodyPoint(record)

		if bodyResult then
			local score = bodyResult.Score

			if Config.StickyTarget
				and record.Player == State.CurrentTarget then

				score -= Config.TargetSwitchPenalty
			end

			if not best or score < best.Score then
				best = {
					Player = record.Player,
					Record = record,
					Part = bodyResult.Part,
					Region = bodyResult.Region,
					Point = bodyResult.Point,

					LocalOffset =
						bodyResult.Part.CFrame:
						PointToObjectSpace(
							bodyResult.Point
						),

					Score = score,
					IsCenter = bodyResult.IsCenter,
					Visible = true,
				}
			end
		end

		-- The normal budget protects mobile performance. If every player in
		-- that first group is blocked, keep scanning until one valid target is
		-- found instead of incorrectly reporting that no target exists.
		if best and index >= maxPlayers then
			break
		end

		index += 1
	end

	if best then
		State.Debug.LastReason =
			best.IsCenter
			and "Centro exato da parte"
			or "Ponto visível da parte"
		State.Debug.LastScore = best.Score
		State.Debug.LastRegion = best.Region
		State.Debug.LastDistance =
			(best.Part.Position - S.Camera.CFrame.Position).Magnitude
	else
		local primaryRegion = BodyRegions[Config.PrimaryBodyRegion]
		State.Debug.LastReason =
			Config.ExactBodyAim
			and (
				"Nenhum ponto visível em "
				.. tostring(
					primaryRegion and primaryRegion.Label
					or Config.PrimaryBodyRegion
				)
			)
			or "Nenhum jogador disponível"
		State.Debug.LastScore = nil
		State.Debug.LastRegion = nil
		State.Debug.LastDistance = nil
	end

	return best
end

-- A swipe changes the selected player synchronously. It never suspends the
-- scanner or the regular aim loop, and there is no active/settling lock.
function TargetSwipe.IsEnabled()
	return Config.MobileFriendlySwitch == true and S.UIS.TouchEnabled == true
end

function TargetSwipe.CanReceiveInput()
	return TargetSwipe.IsEnabled() and Config.AimEnabled == true
		and S.Workspace.CurrentCamera ~= nil and Util.LocalCharacterAlive()
end

function TargetSwipe.CancelTransition()
	State.Swipe.Transition = nil
end

function TargetSwipe.Cancel(reason)
	TargetSwipe.CancelTransition()
	if State.UI.ResetWorldGestureInput then
		State.UI.ResetWorldGestureInput()
	end
	if reason then State.Swipe.LastResult = reason end
end

function TargetSwipe.Record(player)
	if not player or player.Parent ~= S.Players then return nil end
	local record = State.Records[player] or PlayerCache.Get(player)
	local character = player.Character
	if not character or not character.Parent
		or not character:IsDescendantOf(S.Workspace) then
		return nil
	end
	if record.Character ~= character then
		record = PlayerCache.BindCharacter(player, character)
		if BindImmediateESPCharacterEvents then
			BindImmediateESPCharacterEvents(player, record)
		end
	elseif not record.Root or not record.Root.Parent then
		PlayerCache.RefreshBodyParts(record)
	end
	return record
end

function TargetSwipe.BodyPoint(record)
	if not record or not S.Camera then return nil end
	-- The manual choice may leave the normal FOV. All body, life, protection
	-- and visibility rules still apply through the shared body resolver.
	local result = Aim.ResolveBestBodyPoint(record, true)
	if result then
		result.LocalOffset = result.Part.CFrame:PointToObjectSpace(result.Point)
	end
	return result
end

function TargetSwipe.Anchor(record, cameraPosition)
	-- Use the same anatomical reference for every player. Head offsets and
	-- fallback body points must not reorder neighbours during the gesture.
	for _, key in ipairs({"Root", "Torso", "Head"}) do
		local part = record[key]
		if PlayerCache.PartBelongsToRecord(record, part)
			and (part.Position - cameraPosition).Magnitude > 0.001 then
			return part.Position
		end
	end
	for _, region in ipairs(BodyRegionOrder) do
		for _, part in ipairs((record.BodyParts and record.BodyParts[region]) or {}) do
			if PlayerCache.PartBelongsToRecord(record, part)
				and (part.Position - cameraPosition).Magnitude > 0.001 then
				return part.Position
			end
		end
	end
	return nil
end

function TargetSwipe.MakeSnapshot(referenceFrame)
	local snapshot = {
		Camera = referenceFrame,
		Source = State.CurrentTarget,
		SourceYaw = 0,
		SourcePitch = 0,
		Players = {},
	}
	for _, player in ipairs(S.Players:GetPlayers()) do
		if player ~= S.LocalPlayer and player.Parent == S.Players
			and Aim.PlayerAllowed(player) then
			-- A partially streamed or malformed character cannot abort the
			-- entire choice. Only that player's entry is skipped.
			local ok, entry = pcall(function()
				local record = TargetSwipe.Record(player)
				if not record or not PlayerCache.IsAlive(record) then return nil end
				local point = TargetSwipe.Anchor(record, referenceFrame.Position)
				if not point then return nil end
				local localPoint = referenceFrame:PointToObjectSpace(point)
				local direction = localPoint.Unit
				return {
					Player = player, Record = record,
					Yaw = math.atan2(direction.X, -direction.Z),
					Pitch = math.asin(math.clamp(direction.Y, -1, 1)),
				}
			end)
			if ok and entry then
				snapshot.Players[#snapshot.Players + 1] = entry
				if player == snapshot.Source then
					snapshot.SourceYaw = entry.Yaw
					snapshot.SourcePitch = entry.Pitch
				end
			end
		end
	end
	return snapshot
end

function TargetSwipe.Pick(snapshot, direction)
	local candidates = {}
	local epsilon = 1e-7
	local sourceId = snapshot.Source and snapshot.Source.UserId or 0
	for _, entry in ipairs(snapshot.Players) do
		if entry.Player ~= snapshot.Source then
			local difference = entry.Yaw - snapshot.SourceYaw
			local advance = math.atan2(math.sin(difference), math.cos(difference)) * direction
			if math.abs(math.abs(advance) - math.pi) <= epsilon then advance = math.pi end
			if advance >= -epsilon then
				entry.Advance = math.max(advance, 0)
				entry.Vertical = math.abs(entry.Pitch - snapshot.SourcePitch)
				entry.OverlapOrder = (entry.Player.UserId - sourceId) * direction
				candidates[#candidates + 1] = entry
			end
		end
	end

	-- Quantized keys form a strict total order; epsilon comparisons directly
	-- inside table.sort can violate transitivity when several players overlap.
	for _, entry in ipairs(candidates) do
		entry.AngleKey = math.floor(entry.Advance / epsilon + 0.5)
		entry.HeightKey = math.floor(entry.Vertical / epsilon + 0.5)
	end
	table.sort(candidates, function(a, b)
		if a.AngleKey ~= b.AngleKey then return a.AngleKey < b.AngleKey end
		if a.AngleKey == 0 then
			local aForward, bForward = a.OverlapOrder > 0, b.OverlapOrder > 0
			if aForward ~= bForward then return aForward end
			if a.OverlapOrder ~= b.OverlapOrder then return a.OverlapOrder < b.OverlapOrder end
		end
		if a.HeightKey ~= b.HeightKey then return a.HeightKey < b.HeightKey end
		return a.Player.UserId < b.Player.UserId
	end)

	State.Debug.Candidates = #candidates
	-- Check expensive body points in the already determined order. Distance,
	-- precision and FOV never push a farther neighbour ahead of a nearer one.
	for _, entry in ipairs(candidates) do
		local ok, result = pcall(function()
			local player = entry.Player
			if player.Parent ~= S.Players or not Aim.PlayerAllowed(player) then return nil end
			local record = TargetSwipe.Record(player)
			if not record or not PlayerCache.IsAlive(record) then return nil end
			local body = TargetSwipe.BodyPoint(record)
			if not body then return nil end
			body.Player, body.Record = player, record
			body.Direction = direction
			body.Visible = true
			return body
		end)
		if ok and result then return result end
	end
	return nil
end

function TargetSwipe.Assign(candidate)
	State.CurrentTarget = candidate.Player
	State.CurrentPart = candidate.Part
	State.CurrentRegion = candidate.Region
	State.CurrentLocalOffset = candidate.LocalOffset
	State.LastTargetSeen = os.clock()
	if candidate.Visible == true then State.LastTargetVisible = os.clock() end
	State.Debug.LastScore = Persistence.FiniteNumber(candidate.Score, nil)
	State.Debug.LastRegion = candidate.Region
	State.Debug.LastDistance = candidate.WorldDistance
		or (candidate.Point and S.Camera and (candidate.Point - S.Camera.CFrame.Position).Magnitude)
end

function TargetSwipe.StartTransition(candidate)
	TargetSwipe.CancelTransition()
	-- Other response settings already have their own axis-aware smoothing.
	if not Aim.IsMaximumResponse() or not S.Camera then return end
	local frame = S.Camera.CFrame
	local offset = candidate.Point - frame.Position
	if offset.Magnitude <= 0.001 then return end
	local angle = math.acos(math.clamp(frame.LookVector:Dot(offset.Unit), -1, 1))
	local minimum = math.clamp(Config.MobileFriendlyTransitionMin, 0.05, 0.6)
	local maximum = math.clamp(Config.MobileFriendlyTransitionMax, minimum, 0.8)
	State.Swipe.Transition = {
		Player = candidate.Player,
		Camera = S.Camera,
		From = frame - frame.Position,
		Elapsed = 0,
		Duration = minimum + (maximum - minimum) * math.clamp(angle / math.pi, 0, 1),
	}
end

function TargetSwipe.ApplyTransition(targetPoint, deltaTime)
	local transition = State.Swipe.Transition
	if not transition then return false end
	if not TargetSwipe.IsEnabled() or not Aim.IsMaximumResponse()
		or transition.Player ~= State.CurrentTarget or transition.Camera ~= S.Camera then
		TargetSwipe.CancelTransition()
		return false
	end
	local cameraPosition = S.Camera.CFrame.Position
	local offset = targetPoint - cameraPosition
	if offset.Magnitude <= 0.001 then
		TargetSwipe.CancelTransition()
		return false
	end
	transition.Elapsed = math.min(transition.Elapsed + math.max(deltaTime or 1 / 60, 0), transition.Duration)
	local progress = transition.Elapsed / transition.Duration
	local eased = 1 - (1 - progress) ^ 3
	local targetRotation = CFrame.lookAt(Vector3.zero, offset.Unit)
	S.Camera.CFrame = CFrame.new(cameraPosition) * transition.From:Lerp(targetRotation, eased)
	if progress >= 1 then TargetSwipe.CancelTransition() end
	return true
end

function TargetSwipe.Request(horizontalDelta, referenceFrame)
	if not TargetSwipe.CanReceiveInput() then return false end
	local movement = Persistence.FiniteNumber(horizontalDelta, 0)
	if movement == 0 then return false end
	S.Camera = S.Workspace.CurrentCamera
	local direction = movement > 0 and 1 or -1
	if Config.MobileFriendlyInvertGesture then direction = -direction end

	local ok, candidate = pcall(function()
		local snapshot = TargetSwipe.MakeSnapshot(referenceFrame or S.Camera.CFrame)
		return TargetSwipe.Pick(snapshot, direction)
	end)
	if not ok then
		State.LastRuntimeError = string.sub(tostring(candidate), 1, 240)
		State.Swipe.LastResult = "Gesto não aplicado; alvo mantido"
		return false
	end
	if not candidate then
		State.Swipe.LastResult = "Nenhum outro alvo nessa direção"
		return false
	end

	-- Nothing was cleared while searching. A valid destination is committed
	-- in this event, even if the previous camera transition is still running.
	local selectionChanged = Config.AimMode == "SELECTED"
	if selectionChanged then
		table.clear(State.SelectedPlayers)
		State.SelectedPlayers[candidate.Player] = true
	end
	TargetSwipe.Assign(candidate)
	State.Swipe.LastResult = direction > 0 and "Alvo à direita" or "Alvo à esquerda"
	State.Debug.LastReason = State.Swipe.LastResult
	local transitionOk, transitionError = pcall(TargetSwipe.StartTransition, candidate)
	if not transitionOk then
		TargetSwipe.CancelTransition()
		State.LastRuntimeError = string.sub(tostring(transitionError), 1, 240)
	end
	if State.UI.OnSwipeTargetChanged then
		-- UI failures must not undo a successful target change.
		pcall(State.UI.OnSwipeTargetChanged, candidate.Player, selectionChanged)
	end
	return true
end

function TargetSwipe.RetainedCandidate()
	if not TargetSwipe.IsEnabled() then return nil end
	local player = State.CurrentTarget
	if not player or player.Parent ~= S.Players or not Aim.PlayerAllowed(player)
		or (Config.AimMode == "SELECTED" and not State.SelectedPlayers[player]) then
		return nil
	end
	local record = TargetSwipe.Record(player)
	if not record or not PlayerCache.IsAlive(record) then return nil end
	local part, region = State.CurrentPart, State.CurrentRegion
	local offset = State.CurrentLocalOffset
	local point = nil
	if region and Aim.RegionEnabled(region) and PlayerCache.PartBelongsToRecord(record, part)
		and (not Config.StrictBodyRegion or Config.BodyFallback or region == Config.PrimaryBodyRegion) then
		point = offset and part.CFrame:PointToWorldSpace(offset) or part.Position
	end
	local visible = point ~= nil and Aim.PointVisible(record, point)
	local replacement = nil
	if Config.StrictBodyRegion and region ~= Config.PrimaryBodyRegion then
		replacement = Aim.ResolveRegionPoint(record, Config.PrimaryBodyRegion, true)
	end
	if not replacement and not visible then replacement = TargetSwipe.BodyPoint(record) end
	if replacement then
		part, region, point = replacement.Part, replacement.Region, replacement.Point
		offset = replacement.LocalOffset or part.CFrame:PointToObjectSpace(point)
		visible = true
	end
	if not point then return nil end
	if not visible and (Config.StrictWallCheck or os.clock() - State.LastTargetVisible > Config.WallGrace) then
		return nil
	end
	return {
		Player = player, Record = record, Part = part, Region = region,
		Point = point, LocalOffset = offset, Score = -math.huge, Visible = visible,
		WorldDistance = (point - S.Camera.CFrame.Position).Magnitude,
	}
end

function TargetSwipe.RefreshCurrent()
	if not TargetSwipe.IsEnabled() then return false, nil end
	local candidate = TargetSwipe.RetainedCandidate()
	if not candidate then return false, false end
	TargetSwipe.Assign(candidate)
	return true, candidate.Visible
end


function Aim.GetPredictionTime(part)
	if not Config.Prediction then
		return 0
	end

	if Config.PredictionMode == "MANUAL" then
		return math.clamp(
			Config.PredictionTime,
			Config.PredictionMin,
			Config.PredictionMax
		)
	end

	local distance =
		(part.Position - S.Camera.CFrame.Position).Magnitude

	local velocity =
		part.AssemblyLinearVelocity.Magnitude

	local distanceFactor =
		math.clamp(
			distance / 900,
			0,
			1
		)

	local velocityFactor =
		math.clamp(
			velocity / 90,
			0,
			1
		)

	local prediction =
		Config.PredictionMin
		+
		(
			Config.PredictionMax
			-
			Config.PredictionMin
		)
		*
		(
			distanceFactor * 0.55
			+
			velocityFactor * 0.45
		)

	prediction *= Aim.EffectivePredictionScale()

	return math.clamp(
		prediction,
		Config.PredictionMin,
		Config.PredictionMax
	)
end

function Aim.DistanceCorrectedBodyPoint(part, basePoint)
	if not Config.LongRangeCorrection
		or State.CurrentRegion ~= "Head"
		or not Config.ExactBodyAim then

		return basePoint
	end

	local cameraPosition =
		S.Camera.CFrame.Position

	local distance =
		(basePoint - cameraPosition).Magnitude

	if distance <= Config.LongRangeStart then
		return basePoint
	end

	local range =
		math.max(
			Config.LongRangeFull
			-
			Config.LongRangeStart,
			1
		)

	local t =
		math.clamp(
			(
				distance
				-
				Config.LongRangeStart
			)
			/
			range,
			0,
			1
		)

	-- Offset is relative to the actual head height. At maximum range
	-- this is only a small fraction of the Head part, enough to remove
	-- the perceived low bias without aiming above the avatar.
	local localLift =
		part.Size.Y
		*
		Config.LongRangeHeadLift
		*
		t

	local localPoint = part.CFrame:PointToObjectSpace(basePoint)
	local halfHeight = math.max(part.Size.Y * 0.5 - 0.001, 0)
	local corrected = Vector3.new(localPoint.X,
		math.clamp(localPoint.Y + localLift, -halfHeight, halfHeight), localPoint.Z)
	return part.CFrame:PointToWorldSpace(corrected)
end

function Aim.PredictedPosition(part, basePoint)
	basePoint =
		basePoint
		or part.Position

	basePoint =
		Aim.DistanceCorrectedBodyPoint(
			part,
			basePoint
		)

	if not Config.Prediction then
		return basePoint
	end

	local velocity =
		part.AssemblyLinearVelocity

	local fromCamera =
		basePoint
		-
		S.Camera.CFrame.Position

	local distance =
		fromCamera.Magnitude

	if distance <= 0.001 then
		return basePoint
	end

	local sightDirection =
		fromCamera.Unit

	local forwardComponent =
		sightDirection
		*
		velocity:Dot(
			sightDirection
		)

	local lateralVelocity =
		velocity
		-
		forwardComponent

	if lateralVelocity.Magnitude < 0.75 then
		return basePoint
	end

	local regionScale = 1

	if State.CurrentRegion == "Head" then
		regionScale =
			Config.HeadPredictionScale
	elseif State.CurrentRegion == "LeftArm"
		or State.CurrentRegion == "RightArm"
		or State.CurrentRegion == "LeftLeg"
		or State.CurrentRegion == "RightLeg" then

		regionScale =
			Config.LimbPredictionScale
	end

	local predicted =
		basePoint
		+
		lateralVelocity
		*
		Aim.GetPredictionTime(part)
		*
		regionScale

	local blend = 1

	if Config.ExactBodyAim then
		blend =
			Config.ExactBodyPredictionBlend
	end

	local screenError =
		Aim.ScreenDistance(
			basePoint
		)

	if screenError
		and screenError <= Config.NearTargetRadius then

		blend =
			math.min(
				blend,
				Config.NearTargetPredictionBlend
			)
	end

	return basePoint:Lerp(
		predicted,
		math.clamp(
			blend,
			0,
			1
		)
	)
end

function Aim.DistanceStrengthMultiplier(point)
	if not Config.DistanceCompensation then
		return 1
	end

	local distance =
		(point - S.Camera.CFrame.Position).Magnitude

	local t =
		math.clamp(
			distance / 900,
			0,
			1
		)

	return
		Config.DistanceStrengthMax
		+
		(
			Config.DistanceStrengthMin
			-
			Config.DistanceStrengthMax
		)
		*
		t
end

function Aim.BaseAlpha(point)
	local accuracy =
		math.clamp(
			Config.Accuracy,
			0,
			100
		)

	local strength =
		Aim.EffectiveStrength()

	local smoothing =
		Aim.EffectiveSmoothing()

	local alpha =
		(accuracy / 100)
		*
		(strength / 100)
		*
		(
			0.10
			+
			(1 - smoothing / 100) * 0.90
		)

	if Config.SmoothingCurve == "DYNAMIC" then
		local projected =
			S.Camera:WorldToViewportPoint(point)

		local viewport =
			S.Camera.ViewportSize

		local center =
			Vector2.new(
				viewport.X * 0.5,
				viewport.Y * 0.5
			)

		local distance =
			(
				Vector2.new(
					projected.X,
					projected.Y
				)
				-
				center
			).Magnitude

		local dynamicFactor =
			math.clamp(
				distance
				/
				math.max(
					Aim.EffectiveFOV(),
					1
				),
				0.25,
				1
			)

		alpha *= dynamicFactor
	end

	alpha *=
		Aim.DistanceStrengthMultiplier(point)

	return math.clamp(
		alpha,
		0,
		1
	)
end

function Aim.IsMaximumResponse()
	return Config.SnapAtMaximum
		and Config.Accuracy >= 99
		and Aim.EffectiveStrength() >= 99
		and Aim.EffectiveSmoothing() <= 1
		and Config.HorizontalStrength >= 99
		and Config.VerticalStrength >= 99
end

function Aim.Apply(part, deltaTime)
	if Config.Accuracy <= 0 or Aim.EffectiveStrength() <= 0 then
		TargetSwipe.CancelTransition()
		return
	end
	if Config.HorizontalStrength < 100 or Config.VerticalStrength < 100 then
		TargetSwipe.CancelTransition()
	end
	if Config.HorizontalStrength <= 0 and Config.VerticalStrength <= 0 then
		return
	end
	local cameraPosition =
		S.Camera.CFrame.Position

	local basePoint =
		Aim.CurrentAimPoint()
		or part.Position

	local targetPoint =
		Aim.PredictedPosition(
			part,
			basePoint
		)

	local currentDirection =
		S.Camera.CFrame.LookVector

	local desiredVector =
		targetPoint - cameraPosition

	if desiredVector.Magnitude <= 0.001 then
		return
	end

	local desiredDirection =
		desiredVector.Unit

	if TargetSwipe.ApplyTransition(targetPoint, deltaTime) then
		return
	end

	local baseAlpha =
		Aim.BaseAlpha(targetPoint)

	local screenError =
		Aim.ScreenDistance(
			targetPoint
		)

	if screenError
		and screenError <= Config.MicroCorrectionRadius then

		baseAlpha =
			math.clamp(
				baseAlpha
				*
				Config.MicroCorrectionBoost,
				0,
				1
			)
	end

	local horizontal =
		math.clamp(
			Config.HorizontalStrength / 100,
			0,
			1
		)

	local vertical =
		math.clamp(
			Config.VerticalStrength / 100,
			0,
			1
		)

	-- Maximum response removes artificial delay while preserving prediction.
	if Aim.IsMaximumResponse() then
		local tolerance = Config.CenterLockTolerance
		if Config.ScreenConvergence and Config.ExactBodyAim then
			tolerance = math.min(tolerance, Config.ScreenConvergencePixels)
		end
		if screenError
			and screenError <= tolerance then

			return
		end

		S.Camera.CFrame =
			CFrame.lookAt(
				cameraPosition,
				targetPoint
			)

		return
	end

	-- Frame-rate independent interpolation.
	local response =
		math.max(
			Config.ResponseSpeed
			*
			baseAlpha,
			0
		)

	local frameAlpha =
		1
		-
		math.exp(
			-response
			*
			math.max(
				deltaTime or 1 / 60,
				1 / 240
			)
		)

	local xAlpha =
		math.clamp(
			frameAlpha * horizontal,
			0,
			1
		)

	local yAlpha =
		math.clamp(
			frameAlpha * vertical,
			0,
			1
		)

	-- Blend horizontal direction on the XZ plane independently.
	local currentFlat =
		Vector3.new(
			currentDirection.X,
			0,
			currentDirection.Z
		)

	local desiredFlat =
		Vector3.new(
			desiredDirection.X,
			0,
			desiredDirection.Z
		)

	local flatDirection

	if currentFlat.Magnitude > 0.001
		and desiredFlat.Magnitude > 0.001 then

		local currentYaw = math.atan2(currentFlat.X, -currentFlat.Z)
		local desiredYaw = math.atan2(desiredFlat.X, -desiredFlat.Z)
		local yawDelta = math.atan2(math.sin(desiredYaw - currentYaw), math.cos(desiredYaw - currentYaw))
		local yaw = currentYaw + yawDelta * xAlpha
		flatDirection = Vector3.new(math.sin(yaw), 0, -math.cos(yaw))
	else
		flatDirection = currentFlat.Magnitude > 0.001 and currentFlat.Unit
			or (desiredFlat.Magnitude > 0.001 and desiredFlat.Unit)
			or Vector3.new(0, 0, -1)
	end

	local newY =
		currentDirection.Y
		+
		(
			desiredDirection.Y
			-
			currentDirection.Y
		)
		*
		yAlpha

	newY =
		math.clamp(
			newY,
			-0.999,
			0.999
		)

	local horizontalMagnitude =
		math.sqrt(
			math.max(
				1 - newY * newY,
				0.0001
			)
		)

	local finalDirection =
		Vector3.new(
			flatDirection.X * horizontalMagnitude,
			newY,
			flatDirection.Z * horizontalMagnitude
		).Unit

	S.Camera.CFrame =
		CFrame.lookAt(
			cameraPosition,
			cameraPosition + finalDirection
		)
end


function Aim.ApplyScreenConvergence()
	-- Applied by Aim.Apply together with CenterLockTolerance.
end

--==============================================================
-- UI CORE
--==============================================================

local UI = {}

-- Touch-first feedback that never mutates the control's real Size.
-- UIScale avoids cumulative shrink/grow drift on rapid taps.
function UI.TouchFeedback(guiObject)
	if not guiObject or not guiObject:IsA("GuiObject") then
		return nil
	end

	local scale = guiObject:FindFirstChild("AAP_TouchScale")
	if not scale then
		scale = Util.New("UIScale", {
			Name = "AAP_TouchScale",
			Scale = 1,
		}, guiObject)
	end

	local pressedInput = nil

	guiObject.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.Touch
			or input.UserInputType == Enum.UserInputType.MouseButton1 then
			if pressedInput and pressedInput ~= input then
				return
			end

			pressedInput = input
			Util.Tween(scale, {Scale = 0.975}, 0.08)
		end
	end)

	guiObject.InputEnded:Connect(function(input)
		if input == pressedInput then

			pressedInput = nil
			Util.Tween(scale, {Scale = 1}, 0.12)
		end
	end)

	guiObject.MouseLeave:Connect(function()
		if pressedInput then
			pressedInput = nil
			Util.Tween(scale, {Scale = 1}, 0.12)
		end
	end)

	return scale
end

function UI.ApplyTheme(themeName)
	local preset = ThemePresets[themeName] or ThemePresets.RED
	local resolvedName = ThemePresets[themeName] and themeName or "RED"

	Config.UITheme = resolvedName
	for _, key in ipairs(Util.ThemeColorKeys) do
		if preset[key] then
			Theme[key] = preset[key]
		end
	end

	local root = State.UI.Root
	if not root or not root.Parent then
		return resolvedName
	end

	local objects = {root}
	for _, descendant in ipairs(root:GetDescendants()) do
		objects[#objects + 1] = descendant
	end

	local properties = {
		"BackgroundColor3",
		"TextColor3",
		"TextStrokeColor3",
		"ImageColor3",
		"PlaceholderColor3",
		"ScrollBarImageColor3",
		"Color",
	}

	for _, object in ipairs(objects) do
		for _, property in ipairs(properties) do
			local key = object:GetAttribute("AAPTheme_" .. property)
			if key and Theme[key] then
				pcall(function()
					object[property] = Theme[key]
				end)
			end
		end

		if object:IsA("UIGradient") then
			local key1 = object:GetAttribute("AAPTheme_C1")
			local key2 = object:GetAttribute("AAPTheme_C2")

			if key1 or key2 then
				local keypoints = object.Color.Keypoints
				local c1 = key1 and Theme[key1] or keypoints[1].Value
				local c2 = key2 and Theme[key2] or keypoints[#keypoints].Value
				object.Color = ColorSequence.new(c1, c2)
			end
		end
	end

	if State.UI.ActivePage and UI.ShowPage then
		UI.ShowPage(State.UI.ActivePage)
	end

	if State.UI.RefreshPlayerDirectory then State.UI.RefreshPlayerDirectory() end

	if UI.ApplyFOVStyle then
		UI.ApplyFOVStyle(Config.FOVStyle)
	end

	if ESP and ESP.RefreshAll then
		ESP.RefreshAll()
	end

	return resolvedName
end

function UI.ApplyFOVStyle(styleName)
	local style = FOV_STYLE_LABELS[styleName] and styleName or "TACTICAL"
	Config.FOVStyle = style

	local stroke = State.UI.FOVStroke
	local elements = State.UI.FOVElements
	if not stroke or not elements then
		return style
	end

	local showInner = style == "TACTICAL" or style == "DUAL"
	local showCross = style == "CROSS"
		or style == "DUAL"
		or style == "PRECISION"
	local showDot = style == "DOT"
		or style == "CROSS"
		or style == "TACTICAL"
		or style == "PRECISION"
	local showTicks = style == "TACTICAL"
		or style == "PRECISION"

	stroke.Thickness = style == "PRECISION" and 1 or 2
	stroke.Transparency = style == "PRECISION" and 0.10 or 0.18

	if elements.GlowStroke then
		elements.GlowStroke.Enabled = false
	end

	if elements.InnerStroke then
		elements.InnerStroke.Thickness = 1
		elements.InnerStroke.Transparency = 0.26
	end

	if elements.Inner then
		elements.Inner.Visible = showInner
	end
	if elements.Horizontal then
		elements.Horizontal.Visible = showCross
	end
	if elements.Vertical then
		elements.Vertical.Visible = showCross
	end
	if elements.Dot then
		elements.Dot.Visible = showDot
	end
	for _, tick in ipairs(elements.Ticks or {}) do
		tick.Visible = showTicks
	end

	return style
end

function UI.SetFOVStateColor(color)
	if State.UI.FOVStroke then
		State.UI.FOVStroke.Color = color
	end

	local elements = State.UI.FOVElements
	if not elements then
		return
	end

	if elements.GlowStroke then
		elements.GlowStroke.Color = color
	end
	if elements.InnerStroke then
		elements.InnerStroke.Color = color
	end
	if elements.Dot then
		elements.Dot.BackgroundColor3 = color
	end
	for _, line in ipairs(elements.Lines or {}) do
		line.BackgroundColor3 = color
	end
end

function UI.Toast(message)
	if not State.UI.Root or not State.UI.Root.Parent then
		return
	end

	if State.UI.CurrentToast then
		State.UI.CurrentToast:Destroy()
		State.UI.CurrentToast = nil
	end

	local viewport = S.Camera and S.Camera.ViewportSize
		or Vector2.new(800, 450)
	local toastWidth = math.min(
		380,
		math.max(viewport.X - 28, 240)
	)
	local toast = Util.New("Frame", {
		Name = "Toast",
		AnchorPoint = Vector2.new(0.5, 1),
		Position = UDim2.new(0.5, 0, 1, 60),
		Size = UDim2.fromOffset(toastWidth, 50),
		BackgroundColor3 = Color3.new(1, 1, 1),
		BackgroundTransparency = 0.04,
		BorderSizePixel = 0,
		ZIndex = 80,
	}, State.UI.Root)

	Util.Corner(toast, 14)
	Util.GlassGradient(
		toast,
		Theme.GlassRaised,
		Theme.AccentDeep,
		0.02,
		0.08,
		90
	)
	Util.Stroke(toast, Theme.Accent, 0.30, 1)
	Util.InnerHighlight(toast, 1, 0.82, 81)

	local dot = Util.New("Frame", {
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.new(0, 13, 0.5, 0),
		Size = UDim2.fromOffset(7, 7),
		BackgroundColor3 = Theme.Accent,
		BorderSizePixel = 0,
		ZIndex = 81,
	}, toast)
	Util.Corner(dot, 999)
	Util.Stroke(dot, Theme.Accent2, 0.18, 2)

	Util.FitText(Util.New("TextLabel", {
		Position = UDim2.fromOffset(29, 5),
		Size = UDim2.new(1, -42, 1, -10),
		BackgroundTransparency = 1,
		Text = tostring(message),
		TextColor3 = Theme.Text,
		Font = Enum.Font.GothamMedium,
		TextSize = 10,
		TextWrapped = true,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Center,
		ZIndex = 81,
	}, toast), 6, 11)

	State.UI.CurrentToast = toast
	Util.Tween(toast, {Position = UDim2.new(0.5, 0, 1, -14)}, 0.20)

	task.delay(2.2, function()
		if not toast.Parent then
			return
		end

		local tween = Util.Tween(
			toast,
			{Position = UDim2.new(0.5, 0, 1, 60)},
			0.18
		)

		if not tween then
			if State.UI.CurrentToast == toast then
				State.UI.CurrentToast = nil
			end
			toast:Destroy()
			return
		end

		tween.Completed:Connect(function()
			if State.UI.CurrentToast == toast then
				State.UI.CurrentToast = nil
			end
			toast:Destroy()
		end)
	end)
end

function UI.CloseChoiceMenu()
	local active = State.UI.ActiveChoiceMenu
	State.UI.ActiveChoiceMenu = nil
	if not active then return end
	for _, connection in ipairs(active.Connections or {}) do connection:Disconnect() end
	if active.Overlay and active.Overlay.Parent then active.Overlay:Destroy() end
	if active.Panel and active.Panel.Parent then active.Panel:Destroy() end
end

function UI.CloseHelpDialog()
	local active = State.UI.ActiveHelpDialog
	State.UI.ActiveHelpDialog = nil
	if not active then return end
	for _, connection in ipairs(active.Connections or {}) do connection:Disconnect() end
	if active.Overlay and active.Overlay.Parent then active.Overlay:Destroy() end
	if active.Panel and active.Panel.Parent then active.Panel:Destroy() end
end

function UI.OpenHelpDialog(title, message)
	local root = State.UI.Root
	if not root or not root.Parent then return false end
	if UI.ActiveNumericSlider then UI.ActiveNumericSlider:FinishEditing(true) end
	UI.CloseChoiceMenu()
	UI.CloseHelpDialog()

	local overlay = Util.New("TextButton", {
		Name = "AAP_HelpOverlay", Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = Color3.fromRGB(0, 0, 0), BackgroundTransparency = 0.42,
		BorderSizePixel = 0, Text = "", AutoButtonColor = false,
		Active = true, Modal = true, ZIndex = 210,
	}, root)
	local panel = Util.New("TextButton", {
		Name = "AAP_HelpPanel", AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		BackgroundColor3 = Theme.Surface2, BackgroundTransparency = 0.01,
		BorderSizePixel = 0, ClipsDescendants = true,
		Text = "", AutoButtonColor = false, Active = true, ZIndex = 211,
	}, root)
	Util.Corner(panel, 16)
	Util.Stroke(panel, Theme.BorderSoft, 0.32, 1)

	Util.New("TextLabel", {
		Position = UDim2.fromOffset(20, 17), Size = UDim2.new(1, -70, 0, 12),
		BackgroundTransparency = 1, Text = "AJUDA",
		TextColor3 = Theme.Accent2, Font = Enum.Font.GothamMedium, TextSize = 9,
		TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 213,
	}, panel)
	Util.FitText(Util.New("TextLabel", {
		Position = UDim2.fromOffset(20, 36), Size = UDim2.new(1, -40, 0, 26),
		BackgroundTransparency = 1, Text = tostring(title or "Como funciona"),
		TextColor3 = Theme.Text, Font = Enum.Font.GothamBold, TextSize = 14,
		TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 213,
	}, panel), 10, 14)
	Util.New("Frame", {
		Position = UDim2.fromOffset(20, 72), Size = UDim2.new(1, -40, 0, 1),
		BackgroundColor3 = Theme.BorderSoft, BackgroundTransparency = 0.60,
		BorderSizePixel = 0, ZIndex = 213,
	}, panel)

	local body = Util.New("ScrollingFrame", {
		Position = UDim2.fromOffset(20, 86), Size = UDim2.new(1, -40, 1, -144),
		BackgroundTransparency = 1, BorderSizePixel = 0,
		CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y,
		ScrollingDirection = Enum.ScrollingDirection.Y, ScrollBarThickness = 2,
		ScrollBarImageColor3 = Theme.Sub, ScrollBarImageTransparency = 0.45,
		ElasticBehavior = Enum.ElasticBehavior.WhenScrollable,
		ClipsDescendants = true, Active = true, ZIndex = 213,
	}, panel)
	Util.New("TextLabel", {
		Size = UDim2.new(1, -6, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1, Text = tostring(message or ""),
		TextColor3 = Theme.Sub, Font = Enum.Font.Gotham, TextSize = 13,
		LineHeight = 1.15, TextWrapped = true, RichText = false,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Top, ZIndex = 213,
	}, body)

	local close = Util.New("TextButton", {
		Name = "AAP_CloseHelp", AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -10, 0, 9), Size = UDim2.fromOffset(32, 28),
		BackgroundColor3 = Theme.Surface3, BackgroundTransparency = 0.48,
		BorderSizePixel = 0, Text = "×", TextColor3 = Theme.Sub,
		Font = Enum.Font.Gotham, TextSize = 18,
		AutoButtonColor = false, ZIndex = 214,
	}, panel)
	Util.Corner(close, 8)
	UI.TouchFeedback(close)
	local confirm = Util.New("TextButton", {
		AnchorPoint = Vector2.new(1, 1), Position = UDim2.new(1, -20, 1, -16),
		Size = UDim2.fromOffset(88, 30),
		BackgroundColor3 = Theme.AccentSoft, BackgroundTransparency = 0.18,
		BorderSizePixel = 0, Text = "Entendi", TextColor3 = Theme.Text,
		Font = Enum.Font.GothamMedium, TextSize = 11,
		AutoButtonColor = false, ZIndex = 213,
	}, panel)
	Util.Corner(confirm, 9)
	Util.Stroke(confirm, Theme.Accent, 0.62, 1)
	UI.TouchFeedback(confirm)

	local function layout()
		local camera = S.Workspace.CurrentCamera or S.Camera
		local viewport = camera and camera.ViewportSize or Vector2.new(800, 450)
		local width = math.max(1, math.min(400, viewport.X - 32))
		local textHeight = 90
		local ok, bounds = pcall(function()
			return game:GetService("TextService"):GetTextSize(tostring(message or ""),
				13, Enum.Font.Gotham, Vector2.new(math.max(width - 46, 1), 10000))
		end)
		if ok then textHeight = math.ceil(bounds.Y * 1.15) end
		local height = math.max(1, math.min(math.max(154 + textHeight, 196), viewport.Y - 32))
		panel.Size = UDim2.fromOffset(width, height)
	end
	layout()
	State.UI.ActiveHelpDialog = {
		Overlay = overlay, Panel = panel,
		Connections = {root:GetPropertyChangedSignal("AbsoluteSize"):Connect(layout)},
	}
	overlay.Activated:Connect(UI.CloseHelpDialog)
	close.Activated:Connect(UI.CloseHelpDialog)
	confirm.Activated:Connect(UI.CloseHelpDialog)
	return true
end

function UI.CreateHelpButton(parent, title, message, position)
	if not parent or not message or message == "" then return nil end
	-- A small visual with a larger hit area; all header controls share y = 17.
	local button = Util.New("TextButton", {
		Name = "AAP_HelpButton", AnchorPoint = Vector2.new(1, 0),
		Position = position or UDim2.new(1, -65, 0, 3),
		Size = UDim2.fromOffset(28, 28), BackgroundTransparency = 1,
		BorderSizePixel = 0, Text = "", AutoButtonColor = false,
		Active = true, ZIndex = 25,
	}, parent)
	local icon = Util.New("TextLabel", {
		AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromOffset(20, 20),
		BackgroundColor3 = Theme.Surface3, BackgroundTransparency = 0.35,
		BorderSizePixel = 0, Text = "?", TextColor3 = Theme.Sub,
		Font = Enum.Font.GothamMedium, TextSize = 12, ZIndex = 26,
	}, button)
	Util.Corner(icon, 999)
	Util.Stroke(icon, Theme.BorderSoft, 0.38, 1)
	UI.TouchFeedback(button)
	button.Activated:Connect(function()
		if not State.UI.LayoutEditMode then UI.OpenHelpDialog(title, message) end
	end)
	return button
end

function UI.OpenChoiceMenu(anchor, title, choices, currentValue, onSelected)
	local root = State.UI.Root
	if not anchor or not anchor.Parent or not root or not root.Parent
		or type(choices) ~= "table" or #choices == 0 or State.UI.LayoutEditMode then
		return false
	end
	if UI.ActiveNumericSlider then UI.ActiveNumericSlider:FinishEditing(true) end
	UI.CloseChoiceMenu()
	UI.CloseHelpDialog()

	local overlay = Util.New("TextButton", {
		Name = "AAP_ChoiceOverlay", Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = Color3.fromRGB(0, 0, 0), BackgroundTransparency = 0.40,
		BorderSizePixel = 0, Text = "", Active = true, Modal = true,
		AutoButtonColor = false, ZIndex = 180,
	}, root)
	local panel = Util.New("TextButton", {
		Name = "AAP_ChoicePanel", AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		BackgroundColor3 = Theme.Surface2, BackgroundTransparency = 0.01,
		BorderSizePixel = 0, Text = "", AutoButtonColor = false,
		Active = true, ClipsDescendants = true, ZIndex = 181,
	}, root)
	Util.Corner(panel, 18)
	Util.Stroke(panel, Theme.BorderSoft, 0.32, 1)
	Util.New("TextLabel", {
		Position = UDim2.fromOffset(20, 16), Size = UDim2.new(1, -70, 0, 12),
		BackgroundTransparency = 1, Text = "ESCOLHA UMA OPÇÃO",
		TextColor3 = Theme.Sub, Font = Enum.Font.GothamMedium, TextSize = 8,
		TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 183,
	}, panel)
	Util.FitText(Util.New("TextLabel", {
		Position = UDim2.fromOffset(20, 34), Size = UDim2.new(1, -40, 0, 24),
		BackgroundTransparency = 1, Text = tostring(title or "Opções"),
		TextColor3 = Theme.Text, Font = Enum.Font.GothamBold, TextSize = 13,
		TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 183,
	}, panel), 10, 14)
	local close = Util.New("TextButton", {
		Name = "AAP_CloseChoice", AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -10, 0, 10), Size = UDim2.fromOffset(30, 28),
		BackgroundColor3 = Theme.Surface3, BackgroundTransparency = 0.45,
		BorderSizePixel = 0, Text = "×", TextColor3 = Theme.Sub,
		Font = Enum.Font.Gotham, TextSize = 16, AutoButtonColor = false, ZIndex = 184,
	}, panel)
	Util.Corner(close, 9)
	UI.TouchFeedback(close)
	local list = Util.New("ScrollingFrame", {
		Name = "AAP_ChoiceList", Position = UDim2.fromOffset(16, 70),
		Size = UDim2.new(1, -32, 1, -106),
		BackgroundTransparency = 1, BorderSizePixel = 0, CanvasSize = UDim2.new(),
		AutomaticCanvasSize = Enum.AutomaticSize.Y, ScrollBarThickness = 3,
		ScrollBarImageColor3 = Theme.Sub, ScrollBarImageTransparency = 0.45,
		ScrollingDirection = Enum.ScrollingDirection.Y,
		ElasticBehavior = Enum.ElasticBehavior.WhenScrollable,
		VerticalScrollBarInset = Enum.ScrollBarInset.ScrollBar,
		ClipsDescendants = true, Active = true, ZIndex = 182,
	}, panel)
	Util.New("UIListLayout", {
		Padding = UDim.new(0, 7), SortOrder = Enum.SortOrder.LayoutOrder,
	}, list)
	Util.New("UIPadding", {
		PaddingLeft = UDim.new(0, 2), PaddingRight = UDim.new(0, 6),
		PaddingTop = UDim.new(0, 2), PaddingBottom = UDim.new(0, 4),
	}, list)
	Util.New("TextLabel", {
		AnchorPoint = Vector2.new(0, 1), Position = UDim2.new(0, 20, 1, -12),
		Size = UDim2.new(1, -40, 0, 14), BackgroundTransparency = 1,
		Text = "Toque em uma opção para aplicar.", TextColor3 = Theme.Sub,
		Font = Enum.Font.Gotham, TextSize = 8,
		TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 183,
	}, panel)
	local menu = {Overlay = overlay, Panel = panel, List = list, Rows = {}, Connections = {}}
	State.UI.ActiveChoiceMenu = menu
	for index, choice in ipairs(choices) do
		local selected = choice.Value == currentValue
		local row = Util.New("TextButton", {
			Name = "AAP_Choice_" .. tostring(index), Size = UDim2.new(1, -2, 0, 64),
			BackgroundColor3 = selected and Theme.CardActive or Theme.Card,
			BackgroundTransparency = selected and 0.04 or 0.20,
			BorderSizePixel = 0, Text = "", AutoButtonColor = false,
			LayoutOrder = index, ZIndex = 183,
		}, list)
		Util.Corner(row, 12)
		Util.Stroke(row, selected and Theme.AccentSoft or Theme.BorderSoft,
			selected and 0.15 or 0.75, 1)
		local radio = Util.New("Frame", {
			AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, 14, 0.5, 0),
			Size = UDim2.fromOffset(18, 18), BackgroundColor3 = Theme.Chip,
			BackgroundTransparency = 0.25, BorderSizePixel = 0, ZIndex = 184,
		}, row)
		Util.Corner(radio, 999)
		Util.Stroke(radio, selected and Theme.Accent2 or Theme.Muted, selected and 0.05 or 0.40, 1)
		if selected then
			local dot = Util.New("Frame", {
				AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5),
				Size = UDim2.fromOffset(8, 8), BackgroundColor3 = Theme.Accent2,
				BorderSizePixel = 0, ZIndex = 185,
			}, radio)
			Util.Corner(dot, 999)
		end
		local label = Util.New("TextLabel", {
			Position = UDim2.fromOffset(46, 12), Size = UDim2.new(1, -60, 0, 18),
			BackgroundTransparency = 1, Text = tostring(choice.Label or choice.Value),
			TextColor3 = Theme.Text, Font = Enum.Font.GothamMedium, TextSize = 11,
			TextWrapped = true, TextXAlignment = Enum.TextXAlignment.Left,
			TextYAlignment = Enum.TextYAlignment.Top, ZIndex = 184,
		}, row)
		local description
		if choice.Description and choice.Description ~= "" then
			description = Util.New("TextLabel", {
				Position = UDim2.fromOffset(46, 34), Size = UDim2.new(1, -60, 0, 24),
				BackgroundTransparency = 1, Text = tostring(choice.Description),
				TextColor3 = Theme.Sub, Font = Enum.Font.Gotham, TextSize = 10,
				TextWrapped = true, TextXAlignment = Enum.TextXAlignment.Left,
				TextYAlignment = Enum.TextYAlignment.Top, ZIndex = 184,
			}, row)
		end
		menu.Rows[#menu.Rows + 1] = {Card = row, Title = label, Description = description, Radio = radio}
		UI.TouchFeedback(row)
		row.Activated:Connect(function()
			-- A second touch on a closing row must not apply the choice twice.
			if State.UI.ActiveChoiceMenu ~= menu or not Runtime.Alive then return end
			UI.CloseChoiceMenu()
			if onSelected then onSelected(choice.Value, choice) end
		end)
	end
	local function measure(label, width)
		local ok, bounds = pcall(function()
			return game:GetService("TextService"):GetTextSize(label.Text, label.TextSize,
				label.Font, Vector2.new(math.max(width, 1), 10000))
		end)
		return ok and math.ceil(bounds.Y) + 2
			or math.ceil(#label.Text * label.TextSize * 0.62 / math.max(width, 1)) * (label.TextSize + 3)
	end
	local function layout()
		local camera = S.Workspace.CurrentCamera or S.Camera
		local viewport = camera and camera.ViewportSize or Vector2.new(800, 450)
		local width = math.max(1, math.min(420, viewport.X - 32))
		local contentHeight = 6 + math.max(#menu.Rows - 1, 0) * 7
		for _, row in ipairs(menu.Rows) do
			local titleHeight = math.max(18, measure(row.Title, width - 106))
			row.Title.Size = UDim2.new(1, -60, 0, titleHeight)
			local height = 24 + titleHeight
			if row.Description then
				local descriptionHeight = math.max(14, measure(row.Description, width - 106))
				row.Description.Position = UDim2.fromOffset(46, 16 + titleHeight)
				row.Description.Size = UDim2.new(1, -60, 0, descriptionHeight)
				height += 4 + descriptionHeight
			end
			height = math.max(height, 48)
			row.Card.Size = UDim2.new(1, -2, 0, height)
			contentHeight += height
		end
		local height = math.min(contentHeight + 106, math.max(viewport.Y - 32, 1), 520)
		panel.Size = UDim2.fromOffset(width, height)
	end
	layout()
	menu.Connections[1] = root:GetPropertyChangedSignal("AbsoluteSize"):Connect(layout)
	overlay.Activated:Connect(UI.CloseChoiceMenu)
	close.Activated:Connect(UI.CloseChoiceMenu)
	return true
end

function UI.BindChoiceMenu(control, title, choices, getCurrent, onSelected)
	if not control or not control.Card then
		return
	end

	control.Card.Activated:Connect(function()
		if control.Available == false or State.UI.LayoutEditMode then return end
		local current = getCurrent
		if type(getCurrent) == "function" then
			current = getCurrent()
		end
		UI.OpenChoiceMenu(
			control.Card,
			title,
			choices,
			current,
			onSelected
		)
	end)
end

UI.ControlRecords = {}
UI.ControlRecordByCard = {}
UI.ScalableControls = {}
UI.DynamicScaledControls = setmetatable({}, {__mode = "k"})
UI.OrganizerContainers = {}
UI.OrganizerContainerCounts = {}
UI.ControlIdCounts = {}
UI.OrganizerReady = false

function UI.PointInside(guiObject, point)
	if not guiObject or not guiObject.Parent or not point then return false end
	local position, size = guiObject.AbsolutePosition, guiObject.AbsoluteSize
	local left: number, top: number = position.X, position.Y
	local right: number, bottom: number = left + size.X, top + size.Y
	local current = guiObject
	while current do
		if current:IsA("GuiObject") then
			if not current.Visible then return false end
			if current ~= guiObject and current.ClipsDescendants then
				local p, s = current.AbsolutePosition, current.AbsoluteSize
				left, top = math.max(left, p.X), math.max(top, p.Y)
				right, bottom = math.min(right, p.X + s.X), math.min(bottom, p.Y + s.Y)
			end
		elseif current:IsA("ScreenGui") and not current.Enabled then
			return false
		end
		current = current.Parent
	end
	return right > left and bottom > top and point.X >= left and point.X <= right
		and point.Y >= top and point.Y <= bottom
end

function UI.GetPageForObject(guiObject)
	local current = guiObject
	local pageHost = State.UI.PageHost

	while current and pageHost do
		if current.Parent == pageHost then
			return current
		end
		current = current.Parent
	end

	return nil
end

function UI.RegisterOrganizerContainer(container, containerId)
	if not container then
		return
	end

	container:SetAttribute("AAPOrganizerContainer", true)
	container:SetAttribute("AAPOrganizerId", containerId)
	UI.OrganizerContainers[containerId] = container
end

function UI.ApplyControlScale(value)
	Config.ControlScale = math.clamp(
		Persistence.FiniteNumber(value, 0.90),
		CONTROL_SCALE_MIN,
		CONTROL_SCALE_MAX
	)

	for _, entry in ipairs(UI.ScalableControls) do
		local card = entry.Card
		if card and card.Parent then
			local height = math.floor(
				entry.BaseHeight * Config.ControlScale + 0.5
			)
			card.Size = UDim2.new(
				card.Size.X.Scale,
				card.Size.X.Offset,
				0,
				height
			)
			local record = UI.ControlRecordByCard[card]
			if record and not State.UI.ActiveControlDrag then
				record.OriginalSize = card.Size
			end
			if record and UI.ApplyOrganizerRecordLayout then
				UI.ApplyOrganizerRecordLayout(record)
			end
		end
	end

	for card, baseHeight in pairs(UI.DynamicScaledControls) do
		if card and card.Parent then
			card.Size = UDim2.new(
				card.Size.X.Scale,
				card.Size.X.Offset,
				0,
				math.floor(baseHeight * Config.ControlScale + 0.5)
			)
		end
	end

	return Config.ControlScale
end

local function organizerSlug(value)
	local slug = string.lower(tostring(value or "controle"))
	slug = slug:gsub("[^%w]+", "_")
	slug = slug:gsub("^_+", ""):gsub("_+$", "")
	return slug ~= "" and slug or "controle"
end

local function makeOrganizerGrip(slot)
	local grip = Util.New("TextButton", {
		Name = "AAP_OrganizerGrip",
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -2, 0.5, 0),
		Size = UDim2.fromOffset(26, 30),
		BackgroundColor3 = Theme.Surface3,
		BackgroundTransparency = 0.20,
		BorderSizePixel = 0,
		Text = "",
		AutoButtonColor = false,
		Active = true,
		Visible = State.UI.LayoutEditMode == true,
		ZIndex = 30,
	}, slot)
	Util.Corner(grip, 999)
	Util.Stroke(grip, Theme.BorderSoft, 0.42, 1)

	for index = 1, 3 do
		local bar = Util.New("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.new(0.5, 0, 0.5, (index - 2) * 4),
			Size = UDim2.fromOffset(10, 2),
			BackgroundColor3 = Theme.Accent2,
			BackgroundTransparency = 0.18 + (index - 1) * 0.16,
			BorderSizePixel = 0,
			ZIndex = 31,
		}, grip)
		Util.Corner(bar, 999)
	end

	return grip
end

function UI.ApplyOrganizerRecordLayout(record)
	if not record
		or not record.Card
		or not record.Content
		or not record.Card.Parent
		or not record.Content.Parent then

		return
	end

	record.Content.AnchorPoint = Vector2.zero
	record.Content.Position = UDim2.new()
	record.Content.Size = State.UI.LayoutEditMode
		and UDim2.new(1, -32, 1, 0)
		or UDim2.fromScale(1, 1)

	if record.Grip and record.Grip.Parent then
		record.Grip.Visible = State.UI.LayoutEditMode
	end
end

function UI.RegisterSharedControl(card, parent, title, baseHeight, options)
	options = options or {}
	local scalable = options.Scalable ~= false
	local scaledHeight = math.floor(
		baseHeight * Config.ControlScale + 0.5
	)

	if options.Organizable == false then
		if scalable then
			UI.ScalableControls[#UI.ScalableControls + 1] = {
				Card = card,
				BaseHeight = baseHeight,
			}
			card.Size = UDim2.new(
				card.Size.X.Scale,
				card.Size.X.Offset,
				0,
				scaledHeight
			)
		end
		return nil
	end

	local page = UI.GetPageForObject(parent)
	if not page then
		if scalable then
			UI.ScalableControls[#UI.ScalableControls + 1] = {
				Card = card,
				BaseHeight = baseHeight,
			}
			card.Size = UDim2.new(
				card.Size.X.Scale,
				card.Size.X.Offset,
				0,
				scaledHeight
			)
		end
		return nil
	end

	local baseId = options.Id
		or (page.Name .. ":" .. organizerSlug(title))
	local count = (UI.ControlIdCounts[baseId] or 0) + 1
	UI.ControlIdCounts[baseId] = count
	local controlId = count == 1 and baseId or (baseId .. ":" .. count)
	local slotHeight = scalable and scaledHeight or card.Size.Y.Offset
	local slot = Util.New("Frame", {
		Name = "AAP_ControlSlot_" .. organizerSlug(controlId),
		Size = UDim2.new(
			card.Size.X.Scale,
			card.Size.X.Offset,
			card.Size.Y.Scale,
			slotHeight
		),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ClipsDescendants = false,
		LayoutOrder = card.LayoutOrder,
	}, parent)

	card.Parent = slot
	card.AnchorPoint = Vector2.zero
	card.Position = UDim2.new()
	card.Size = UDim2.fromScale(1, 1)

	local grip = makeOrganizerGrip(slot)
	local record = {
		Id = controlId,
		Title = title,
		Card = slot,
		Content = card,
		Grip = grip,
		HomeParent = parent,
		HomeOrder = slot.LayoutOrder,
		OriginalSize = slot.Size,
	}

	UI.ControlRecords[#UI.ControlRecords + 1] = record
	UI.ControlRecordByCard[slot] = record
	UI.ControlRecordByCard[card] = record

	if scalable then
		UI.ScalableControls[#UI.ScalableControls + 1] = {
			Card = slot,
			Content = card,
			BaseHeight = baseHeight,
		}
	end

	Runtime.Track(card:GetPropertyChangedSignal("LayoutOrder"):Connect(function()
		if slot.Parent and not State.UI.ActiveControlDrag then
			slot.LayoutOrder = card.LayoutOrder
		end
	end))

	UI.ApplyOrganizerRecordLayout(record)

	grip.InputBegan:Connect(function(input)
		if UI.BeginControlDrag then
			UI.BeginControlDrag(record, input)
		end
	end)

	return record
end

local function organizerChildren(container, excluded)
	local result = {}

	for _, child in ipairs(container:GetChildren()) do
		if child:IsA("GuiObject")
			and child ~= excluded
			and child.Name ~= "AAP_OrganizerPlaceholder" then

			result[#result + 1] = child
		end
	end

	return result
end

function UI.NormalizeOrganizerContainer(container, preserveCreationOrder)
	if not container or not container.Parent then
		return
	end

	local children = organizerChildren(container)
	if not preserveCreationOrder then
		table.sort(children, function(a, b)
			if a.LayoutOrder == b.LayoutOrder then
				return a.AbsolutePosition.Y < b.AbsolutePosition.Y
			end
			return a.LayoutOrder < b.LayoutOrder
		end)
	end

	for index, child in ipairs(children) do
		child.LayoutOrder = index * 100
	end
end

function UI.FindOrganizerContainerAtPoint(page, point)
	if not page or not UI.PointInside(page, point) then
		return nil
	end

	local best = page
	local bestArea = math.max(page.AbsoluteSize.X * page.AbsoluteSize.Y, 1)

	for _, descendant in ipairs(page:GetDescendants()) do
		if descendant:IsA("GuiObject")
			and descendant:GetAttribute("AAPOrganizerContainer") == true
			and UI.PointInside(descendant, point) then

			local size = descendant.AbsoluteSize
			local area = math.max(size.X * size.Y, 1)
			if area < bestArea then
				best = descendant
				bestArea = area
			end
		end
	end

	return best
end

local function activePageName()
	local labels = {
		Aim = "MIRA",
		Assistant = "PERFIS",
		Body = "CORPO",
		Players = "JOGADORES",
		ESP = "ESP",
		Engine = "AJUSTES",
	}
	for name, page in pairs(State.UI.Pages or {}) do
		if page == State.UI.ActivePage then
			return labels[name] or name
		end
	end
	return nil
end

function UI.SaveControlLayout()
	local saved = {}

	for _, record in ipairs(UI.ControlRecords) do
		local card = record.Card
		if card and card.Parent and card.Parent ~= State.UI.Root then
			local page = UI.GetPageForObject(card)
			local containerId = card.Parent:GetAttribute("AAPOrganizerId")
			if page and containerId then
				saved[record.Id] = {
					Page = page.Name,
					Container = containerId,
					Order = card.LayoutOrder,
				}
			end
		end
	end

	Config.MenuControlLayout = saved
end

function UI.ApplySavedControlLayout()
	if not UI.OrganizerReady then
		return false
	end

	for _, record in ipairs(UI.ControlRecords) do
		if record.Card and record.HomeParent and record.HomeParent.Parent then
			record.Card.Parent = record.HomeParent
			record.Card.LayoutOrder = record.HomeOrder
			record.Card.Position = UDim2.new()
		end
	end

	for _, container in pairs(UI.OrganizerContainers) do
		UI.NormalizeOrganizerContainer(container, false)
	end

	local touched = {}
	for _, record in ipairs(UI.ControlRecords) do
		local saved = Config.MenuControlLayout[record.Id]
		if type(saved) == "table" then
			local targetPage = State.UI.Pages and State.UI.Pages[saved.Page]
			local targetContainer = UI.OrganizerContainers[saved.Container]
			if targetPage
				and targetContainer
				and UI.GetPageForObject(targetContainer) == targetPage then

				record.Card.Parent = targetContainer
				record.Card.LayoutOrder = math.floor(
					Persistence.FiniteNumber(saved.Order, 100)
				)
				touched[targetContainer] = true
			end
		end
	end

	for container in pairs(touched) do
		UI.NormalizeOrganizerContainer(container, false)
	end

	return true
end

function UI.PrepareControlOrganizer()
	if UI.OrganizerReady then
		return
	end

	for _, container in pairs(UI.OrganizerContainers) do
		UI.NormalizeOrganizerContainer(container, true)
	end

	for _, record in ipairs(UI.ControlRecords) do
		record.HomeOrder = record.Card.LayoutOrder
		record.OriginalSize = record.Card.Size
	end

	UI.OrganizerReady = true
	UI.ApplySavedControlLayout()
end

function UI.ResetControlLayout()
	if State.UI.ActiveControlDrag and UI.FinishControlDrag then
		UI.FinishControlDrag(nil, false)
	end

	Config.MenuControlLayout = {}
	for _, record in ipairs(UI.ControlRecords) do
		if record.Card and record.HomeParent and record.HomeParent.Parent then
			record.Card.Parent = record.HomeParent
			record.Card.LayoutOrder = record.HomeOrder
			record.Card.Position = UDim2.new()
		end
	end

	for _, container in pairs(UI.OrganizerContainers) do
		UI.NormalizeOrganizerContainer(container, false)
	end
end

function UI.SetControlOrganizerEnabled(enabled)
	State.UI.LayoutEditMode = enabled == true

	if not State.UI.LayoutEditMode
		and State.UI.ActiveControlDrag
		and UI.FinishControlDrag then

		UI.FinishControlDrag(nil, false)
	end

	for _, record in ipairs(UI.ControlRecords) do
		UI.ApplyOrganizerRecordLayout(record)
	end

	if State.UI.RefreshEngineControls then
		State.UI.RefreshEngineControls()
	end
end

local function setOrganizerGhostZIndex(object)
	if object:IsA("GuiObject") then
		object.ZIndex = math.max(object.ZIndex, 140)
	end
	for _, descendant in ipairs(object:GetDescendants()) do
		if descendant:IsA("GuiObject") then
			descendant.ZIndex = math.max(descendant.ZIndex, 141)
		end
	end
end

local function setPageScrolling(enabled)
	for _, page in pairs(State.UI.Pages or {}) do
		if page:IsA("ScrollingFrame") then
			page.ScrollingEnabled = enabled
			local cue = UI.PageScrollCues and UI.PageScrollCues[page]
			if cue then
				if enabled then
					task.defer(function()
						UI.RefreshPageScrollCue(page)
					end)
				else
					cue.Visible = false
				end
			end
		end
	end
end

function UI.BeginControlDrag(record, input)
	if not State.UI.LayoutEditMode
		or State.UI.ActiveControlDrag
		or not record
		or not record.Card
		or not record.Card.Parent then

		return
	end

	if input.UserInputType ~= Enum.UserInputType.Touch
		and input.UserInputType ~= Enum.UserInputType.MouseButton1 then

		return
	end

	UI.PrepareControlOrganizer()
	local card = record.Card
	local absolutePosition = card.AbsolutePosition
	local absoluteSize = card.AbsoluteSize
	local startParent = card.Parent
	local placeholder = Util.New("Frame", {
		Name = "AAP_OrganizerPlaceholder",
		Size = card.Size,
		BackgroundColor3 = Theme.AccentSoft,
		BackgroundTransparency = 0.74,
		BorderSizePixel = 0,
		LayoutOrder = card.LayoutOrder,
	}, startParent)
	Util.Corner(placeholder, 14)
	Util.Stroke(placeholder, Theme.Accent, 0.18, 1)
	Util.New("TextLabel", {
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		Text = "SOLTE AQUI",
		TextColor3 = Theme.Accent2,
		Font = Enum.Font.GothamBold,
		TextSize = 8,
		ZIndex = 32,
	}, placeholder)

	local ghost = card:Clone()
	ghost.Name = "AAP_ControlGhost"
	ghost.AnchorPoint = Vector2.zero
	ghost.Position = UDim2.fromOffset(absolutePosition.X, absolutePosition.Y)
	ghost.Size = UDim2.fromOffset(absoluteSize.X, absoluteSize.Y)
	ghost.Visible = true
	ghost.Parent = State.UI.Root
	local ghostScale = ghost:FindFirstChild("AAP_TouchScale")
	if ghostScale and ghostScale:IsA("UIScale") then
		ghostScale.Scale = 1
	end
	setOrganizerGhostZIndex(ghost)

	record.OriginalSize = card.Size
	card.Parent = State.UI.Root
	card.Visible = false

	State.UI.ActiveControlDrag = {
		Record = record,
		Input = input,
		StartParent = startParent,
		StartOrder = placeholder.LayoutOrder,
		Placeholder = placeholder,
		Ghost = ghost,
		Offset = Vector2.new(
			input.Position.X - absolutePosition.X,
			input.Position.Y - absolutePosition.Y
		),
		HoverButton = nil,
		HoverToken = 0,
		TargetContainer = startParent,
	}

	setPageScrolling(false)
end

local function organizerInputMatches(activeInput, changedInput)
	if not activeInput then
		return false
	end
	if activeInput.UserInputType == Enum.UserInputType.Touch then
		return changedInput == activeInput
	end
	return activeInput.UserInputType == Enum.UserInputType.MouseButton1
		and changedInput.UserInputType == Enum.UserInputType.MouseMovement
end

local function organizerInputFinished(activeInput, endedInput)
	return activeInput == endedInput
		or (
			activeInput
			and activeInput.UserInputType == Enum.UserInputType.MouseButton1
			and endedInput.UserInputType == Enum.UserInputType.MouseButton1
		)
end

local function positionOrganizerPlaceholder(drag, container, point)
	if not drag
		or not drag.Placeholder
		or not drag.Placeholder.Parent
		or not container
		or not container.Parent then

		return false
	end

	local children = organizerChildren(container)
	table.sort(children, function(a, b)
		if a.LayoutOrder == b.LayoutOrder then
			return a.AbsolutePosition.Y < b.AbsolutePosition.Y
		end
		return a.LayoutOrder < b.LayoutOrder
	end)

	local insertIndex = #children + 1
	if point then
		for index, child in ipairs(children) do
			local centerY = child.AbsolutePosition.Y
				+ child.AbsoluteSize.Y * 0.5
			if point.Y < centerY then
				insertIndex = index
				break
			end
		end
	end

	local previousContainer = drag.Placeholder.Parent
	drag.Placeholder.Parent = container
	if previousContainer and previousContainer ~= container then
		UI.NormalizeOrganizerContainer(previousContainer, false)
	end
	table.insert(children, insertIndex, drag.Placeholder)
	for index, child in ipairs(children) do
		child.LayoutOrder = index * 100
	end

	drag.TargetContainer = container
	return true
end

local function updateOrganizerTabHover(drag, point)
	local hoveredButton = nil
	for _, button in pairs(State.UI.Nav or {}) do
		if UI.PointInside(button, point) then
			hoveredButton = button
			break
		end
	end

	if hoveredButton == drag.HoverButton then
		return
	end

	drag.HoverButton = hoveredButton
	drag.HoverToken += 1
	local token = drag.HoverToken

	if not hoveredButton then
		return
	end

	task.delay(0.28, function()
		local active = State.UI.ActiveControlDrag
		if active ~= drag
			or active.HoverButton ~= hoveredButton
			or active.HoverToken ~= token then

			return
		end

		local page = State.UI.PageMap and State.UI.PageMap[hoveredButton]
		if page then
			UI.ShowPage(page)
			task.defer(function()
				local current = State.UI.ActiveControlDrag
				if current == drag and page.Visible then
					positionOrganizerPlaceholder(current, page, nil)
				end
			end)
		end
	end)
end

local function autoScrollOrganizerPage(page, point)
	if not page or not page:IsA("ScrollingFrame") then
		return
	end

	local top = page.AbsolutePosition.Y
	local bottom = top + page.AbsoluteWindowSize.Y
	local margin = math.min(46, page.AbsoluteWindowSize.Y * 0.18)
	local direction = 0
	if point.Y < top + margin then
		direction = -1
	elseif point.Y > bottom - margin then
		direction = 1
	end

	if direction == 0 then
		return
	end

	local maxY = math.max(
		page.AbsoluteCanvasSize.Y - page.AbsoluteWindowSize.Y,
		0
	)
	page.CanvasPosition = Vector2.new(
		0,
		math.clamp(page.CanvasPosition.Y + direction * 18, 0, maxY)
	)
end

function UI.UpdateControlDrag(input)
	local drag = State.UI.ActiveControlDrag
	if not drag or not organizerInputMatches(drag.Input, input) then
		return
	end

	local point = input.Position
	if drag.Ghost and drag.Ghost.Parent then
		drag.Ghost.Position = UDim2.fromOffset(
			point.X - drag.Offset.X,
			point.Y - drag.Offset.Y
		)
	end

	updateOrganizerTabHover(drag, point)
	autoScrollOrganizerPage(State.UI.ActivePage, point)
	local container = UI.FindOrganizerContainerAtPoint(
		State.UI.ActivePage,
		point
	)
	if container then
		positionOrganizerPlaceholder(drag, container, point)
	else
		local previousContainer = drag.Placeholder and drag.Placeholder.Parent
		drag.TargetContainer = nil
		if drag.Placeholder and drag.StartParent.Parent then
			drag.Placeholder.Parent = drag.StartParent
			drag.Placeholder.LayoutOrder = drag.StartOrder
		end
		if previousContainer and previousContainer ~= drag.StartParent then
			UI.NormalizeOrganizerContainer(previousContainer, false)
		end
	end
end

function UI.FinishControlDrag(input, commit)
	local drag = State.UI.ActiveControlDrag
	if not drag then
		return
	end

	local point = input and input.Position or nil
	local targetContainer = nil
	if commit and point then
		targetContainer = UI.FindOrganizerContainerAtPoint(
			State.UI.ActivePage,
			point
		)
		if targetContainer then
			positionOrganizerPlaceholder(drag, targetContainer, point)
		end

		if not targetContainer and drag.HoverButton then
			local hoveredPage = State.UI.PageMap
				and State.UI.PageMap[drag.HoverButton]
			if hoveredPage == State.UI.ActivePage then
				targetContainer = hoveredPage
				point = nil
				positionOrganizerPlaceholder(drag, targetContainer, nil)
			end
		end
	end

	local record = drag.Record
	local card = record.Card
	if targetContainer then
		card.Parent = targetContainer
		card.Size = record.OriginalSize
		card.Position = UDim2.new()
		card.LayoutOrder = drag.Placeholder
			and drag.Placeholder.LayoutOrder
			or card.LayoutOrder
		card.Visible = true
	else
		card.Parent = drag.StartParent
		card.Size = record.OriginalSize
		card.Position = UDim2.new()
		card.LayoutOrder = drag.StartOrder
		card.Visible = true
	end

	if drag.Placeholder then
		drag.Placeholder:Destroy()
	end
	if drag.Ghost then
		drag.Ghost:Destroy()
	end

	State.UI.ActiveControlDrag = nil
	setPageScrolling(true)
	UI.NormalizeOrganizerContainer(drag.StartParent, false)
	if targetContainer and targetContainer ~= drag.StartParent then
		UI.NormalizeOrganizerContainer(targetContainer, false)
	end
	UI.SaveControlLayout()

	if targetContainer then
		UI.Toast(
			"Opção movida para "
			.. string.upper(activePageName() or "ABA")
		)
	elseif commit then
		UI.Toast("Não foi possível mover. A opção voltou ao lugar.")
	end
end

function UI.InitializeControlOrganizer()
	UI.PrepareControlOrganizer()

	Runtime.Track(S.UIS.InputChanged:Connect(function(input)
		UI.UpdateControlDrag(input)
	end))

	Runtime.Track(S.UIS.InputEnded:Connect(function(input)
		local drag = State.UI.ActiveControlDrag
		if drag and organizerInputFinished(drag.Input, input) then
			UI.FinishControlDrag(input, input.UserInputState ~= Enum.UserInputState.Cancel)
		end
	end))
end

function UI.CreateToggle(parent, title, description, options)
	options = options or {}
	local card = Util.New("TextButton", {
		Size = UDim2.new(1, 0, 0, 70),
		BackgroundColor3 = Theme.Card,
		BackgroundTransparency = 0.04,
		BorderSizePixel = 0,
		Text = "",
		AutoButtonColor = false,
	}, parent)

	Util.Corner(card, 16)
	Util.Sheen(card, 0.07)
	local stroke = Util.Stroke(
		card,
		Theme.BorderInner,
		0.68,
		1
	)


	local titleLabel = Util.FitText(Util.New("TextLabel", {
		Position = UDim2.fromOffset(14, 8),
		Size = UDim2.new(1, options.Help and -116 or -86, 0, 17),
		BackgroundTransparency = 1,
		Text = title,
		TextColor3 = Theme.Text,
		Font = Enum.Font.GothamBold,
		TextSize = 9,
		TextXAlignment = Enum.TextXAlignment.Left,
	}, card), 7, 11)

	local descriptionLabel = Util.FitText(Util.New("TextLabel", {
		Position = UDim2.fromOffset(14, 32),
		Size = UDim2.new(1, -28, 1, -38),
		BackgroundTransparency = 1,
		Text = description,
		TextColor3 = Theme.Sub,
		Font = Enum.Font.Gotham,
		TextSize = 8,
		TextWrapped = true,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Top,
	}, card), 6, 8)

	local switch = Util.New("Frame", {
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -13, 0, 4),
		Size = UDim2.fromOffset(46, 26),
		BackgroundColor3 = Theme.Chip,
		BorderSizePixel = 0,
	}, card)
	Util.Corner(switch, 999)
	Util.Sheen(switch, 0.05)
	local switchStroke = Util.Stroke(
		switch,
		Theme.BorderSoft,
		0.30,
		1
	)

	local knob = Util.New("Frame", {
		Position = UDim2.fromOffset(3, 3),
		Size = UDim2.fromOffset(20, 20),
		BackgroundColor3 = Theme.Muted,
		BorderSizePixel = 0,
	}, switch)
	Util.Corner(knob, 999)
	Util.Sheen(knob, 0.02)
	UI.TouchFeedback(card)

	local control = {
		Card = card,
		Title = titleLabel,
		Description = descriptionLabel,
		OriginalDescription = description,
		Switch = switch,
		SwitchStroke = switchStroke,
		Knob = knob,
		Stroke = stroke,
	}
	if options.Help then
		control.Help = UI.CreateHelpButton(
			card,
			title,
			options.Help,
			UDim2.new(1, -65, 0, 3)
		)
	end
	control.Record = UI.RegisterSharedControl(card, parent, title, 70, options)
	return control
end

function UI.SetToggle(control, enabled)
	if not control then
		return
	end

	control.Card.BackgroundColor3 =
		enabled
		and Theme.CardActive
		or Theme.Card

	if control.Stroke then
		control.Stroke.Color =
			enabled
			and Theme.AccentSoft
			or Theme.BorderSoft
	end


	if control.Switch then
		Util.Tween(
			control.Switch,
			{
				BackgroundColor3 =
					enabled
					and Theme.AccentSoft
					or Theme.Chip
			},
			0.10
		)
	end

	if control.SwitchStroke then
		control.SwitchStroke.Color =
			enabled
			and Theme.Accent
			or Theme.BorderSoft
	end

	if control.Knob then
		Util.Tween(
			control.Knob,
			{
				Position =
					enabled
						and UDim2.new(1, -23, 0, 3)
					or UDim2.fromOffset(3, 3),

				BackgroundColor3 =
					enabled
					and Theme.Text
					or Theme.Muted
			},
			0.10
		)
	end
end

function UI.SetControlAvailable(control, available, unavailableText)
	if not control or not control.Card then
		return
	end

	available = available == true
	control.Available = available
	if not available then
		if control.FinishEditing then control:FinishEditing(false) end
		if UI.ActiveSlider == control then UI.ActiveSlider, UI.ActiveSliderInput = nil, nil end
	end
	control.Card.Active = available
	control.Card.BackgroundTransparency = available and 0.04 or 0.30

	if control.Title then
		control.Title.TextTransparency = available and 0 or 0.42
	end
	if control.Description then
		control.Description.Text = available
			and (control.OriginalDescription or control.Description.Text)
			or (unavailableText or "Disponível quando a opção principal estiver ativada.")
		control.Description.TextTransparency = available and 0 or 0.18
	end
	if control.Switch then
		control.Switch.BackgroundTransparency = available and 0 or 0.42
	end
	-- Sliders store a number in Value and their text object in Label.
	local valueLabel = control.Label
		or (typeof(control.Value) == "Instance" and control.Value)
	if valueLabel then
		valueLabel.TextTransparency = available and 0 or 0.38
	end
	if control.RefreshPrecision then control:RefreshPrecision() end
end

function UI.CreateCycle(parent, title, description, options)
	options = options or {}
	local card = Util.New("TextButton", {
		Size = UDim2.new(1, 0, 0, 66),
		BackgroundColor3 = Theme.Card,
		BackgroundTransparency = 0.04,
		BorderSizePixel = 0,
		Text = "",
		AutoButtonColor = false,
	}, parent)

	Util.Corner(card, 16)
	Util.Sheen(card, 0.08)
	Util.Stroke(card, Theme.BorderInner, 0.70, 1)

	local titleLabel = Util.New("TextLabel", {
		Position = UDim2.fromOffset(14, 7),
		Size = UDim2.new(1, options.Help and -155 or -112, 0, 17),
		BackgroundTransparency = 1,
		Text = title,
		TextColor3 = Theme.Text,
		Font = Enum.Font.GothamMedium,
		TextSize = 9,
		TextXAlignment = Enum.TextXAlignment.Left,
	}, card)

	local descriptionLabel = Util.FitText(Util.New("TextLabel", {
		Position = UDim2.fromOffset(14, 30),
		Size = UDim2.new(1, -28, 1, -35),
		BackgroundTransparency = 1,
		Text = description,
		TextColor3 = Theme.Sub,
		Font = Enum.Font.Gotham,
		TextSize = 8,
		TextWrapped = true,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Top,
	}, card), 6, 8)

	local value = Util.New("TextLabel", {
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -12, 0, 5),
		Size = UDim2.fromOffset(92, 24),
		BackgroundColor3 = Theme.CardHover,
		BorderSizePixel = 0,
		Text = "",
		TextColor3 = Theme.Accent,
		Font = Enum.Font.GothamBold,
		TextSize = 8,
	}, card)

	Util.Corner(value, 999)
	Util.Sheen(value, 0.10)
	Util.Stroke(value, Theme.BorderSoft, 0.60, 1)
	UI.TouchFeedback(card)

	local control = {
		Card = card,
		Title = titleLabel,
		Description = descriptionLabel,
		OriginalDescription = description,
		Value = value,
	}
	if options.Help then
		control.Help = UI.CreateHelpButton(
			card,
			title,
			options.Help,
			UDim2.new(1, -110, 0, 3)
		)
	end
	control.Record = UI.RegisterSharedControl(card, parent, title, 66, options)
	return control
end

UI.ActiveSlider = nil
UI.ActiveSliderInput = nil
UI.ActiveNumericSlider = nil

-- Shared by the full-size and compact sliders. These controls only edit the
-- existing setting through its original callback.
function UI.SliderCanInteract(slider)
	return Runtime.Alive and slider.Available ~= false
		and not State.UI.LayoutEditMode
		and not State.UI.ActiveHelpDialog
		and not State.UI.ActiveChoiceMenu
		and slider.Card ~= nil and slider.Card.Parent ~= nil
end

function UI.ParseSliderNumber(text, suffix)
	if type(text) ~= "string" or #text > 48 then return nil end
	text = text:match("^%s*(.-)%s*$")
	local unit = (suffix or ""):match("^%s*(.-)%s*$")
	if unit ~= "" and text:sub(-#unit) == unit then
		text = text:sub(1, #text - #unit):match("^%s*(.-)%s*$")
	end
	text = text:gsub(",", ".")
	if not text:match("^[+-]?%d+%.?%d*$")
		and not text:match("^[+-]?%.%d+$") then return nil end
	local value = tonumber(text)
	if not value or value ~= value or math.abs(value) == math.huge then return nil end
	return value
end

function UI.RefreshSliderPrecision(slider)
	local available = slider.Available ~= false and not State.UI.LayoutEditMode
	if not slider.Editing then
		slider.Label.Text = tostring(math.floor(slider.Value + 0.5)) .. slider.Suffix
	end
	slider.Label.Active = available
	slider.Label.TextEditable = available
	slider.Label.TextTransparency = available and 0 or 0.42
	if slider.ValueStroke then
		slider.ValueStroke.Color = slider.Editing and Theme.Accent or Theme.BorderSoft
		slider.ValueStroke.Transparency = slider.Editing and 0.18 or 0.58
	end
	for _, entry in ipairs({{slider.Decrease, -1}, {slider.Increase, 1}}) do
		local button, direction = entry[1], entry[2]
		if button then
			local enabled = available and (direction < 0 and slider.Value > slider.Min
				or direction > 0 and slider.Value < slider.Max)
			button.Active = enabled
			button.TextTransparency = enabled and 0.12 or 0.65
			button.BackgroundTransparency = enabled and 0.32 or 0.70
		end
	end
end

function UI.SetSliderValue(slider, value, notify)
	if notify and not UI.SliderCanInteract(slider) then return end
	value = Persistence.FiniteNumber(value, slider.Value or slider.Min)
	value = math.clamp(math.floor(math.clamp(value, slider.Min, slider.Max) + 0.5),
		slider.Min, slider.Max)
	-- A profile refresh or a reused body-region control invalidates a draft.
	-- Releasing the keyboard later must never overwrite the newly loaded value.
	if slider.Editing and not notify then slider:FinishEditing(false) end
	local changed = slider.Value ~= value
	slider.Value = value
	local alpha = (value - slider.Min) / math.max(slider.Max - slider.Min, 0.000001)
	slider.Fill.Size = UDim2.fromScale(alpha, 1)
	slider.Thumb.Position = UDim2.new(alpha, 0, 0.5, 0)
	UI.RefreshSliderPrecision(slider)
	if notify and changed and slider.Callback then slider.Callback(value) end
end

function UI.CreateSliderValueBox(parent, position, size, anchorPoint)
	local box = Util.New("TextBox", {
		Name = "AAP_NumericValue",
		AnchorPoint = anchorPoint or Vector2.zero,
		Position = position, Size = size,
		BackgroundColor3 = Theme.Chip, BackgroundTransparency = 0.20,
		BorderSizePixel = 0, Text = "", PlaceholderText = "Valor",
		PlaceholderColor3 = Theme.Dim, TextColor3 = Theme.Accent2,
		Font = Enum.Font.GothamMedium, TextSize = 10,
		ClearTextOnFocus = false, MultiLine = false, RichText = false,
		TextXAlignment = Enum.TextXAlignment.Center,
		ZIndex = 4,
	}, parent)
	Util.Corner(box, 8)
	Util.FitText(box, 7, 10)
	local stroke = Util.Stroke(box, Theme.BorderSoft, 0.58, 1)
	return box, stroke
end

function UI.CreateSliderStepButton(parent, text, position, size, anchorPoint)
	local button = Util.New("TextButton", {
		Name = text == "+" and "AAP_Increase" or "AAP_Decrease",
		AnchorPoint = anchorPoint or Vector2.zero,
		Position = position, Size = size,
		BackgroundColor3 = Theme.Surface3, BackgroundTransparency = 0.32,
		BorderSizePixel = 0, Text = text,
		TextColor3 = Theme.Sub, Font = Enum.Font.GothamMedium, TextSize = 15,
		AutoButtonColor = false, ZIndex = 4,
	}, parent)
	Util.Corner(button, 8)
	Util.Stroke(button, Theme.BorderSoft, 0.72, 1)
	UI.TouchFeedback(button)
	return button
end

function UI.BindSliderPrecision(slider)
	slider.SetValue = UI.SetSliderValue
	slider.RefreshPrecision = UI.RefreshSliderPrecision
	function slider:FinishEditing(commit)
		if not self.Editing then return end
		local text = self.Label.Text
		self.Editing = false
		if UI.ActiveNumericSlider == self then UI.ActiveNumericSlider = nil end
		if self.Label:IsFocused() then self.Label:ReleaseFocus() end
		if commit and UI.SliderCanInteract(self) then
			local value = UI.ParseSliderNumber(text, self.Suffix)
			if value then
				self:SetValue(value, true)
			else
				UI.Toast("Digite um número válido.")
			end
		end
		UI.RefreshSliderPrecision(self)
	end

	slider.Label.Focused:Connect(function()
		if not UI.SliderCanInteract(slider) or UI.ActiveSliderInput then
			slider.Label:ReleaseFocus()
			return
		end
		if UI.ActiveNumericSlider and UI.ActiveNumericSlider ~= slider then
			UI.ActiveNumericSlider:FinishEditing(true)
		end
		UI.ActiveNumericSlider = slider
		slider.Editing = true
		slider.Label.Text = tostring(slider.Value)
		UI.RefreshSliderPrecision(slider)
		slider.Label.CursorPosition = #slider.Label.Text + 1
		slider.Label.SelectionStart = 1
	end)
	slider.Label.FocusLost:Connect(function(_, input)
		local cancelled = input and (input.KeyCode == Enum.KeyCode.Escape
			or input.UserInputState == Enum.UserInputState.Cancel)
		slider:FinishEditing(not cancelled)
	end)
	for _, entry in ipairs({{slider.Decrease, -1}, {slider.Increase, 1}}) do
		local button, direction = entry[1], entry[2]
		button.Activated:Connect(function()
			if not UI.SliderCanInteract(slider) or UI.ActiveSliderInput then return end
			if slider.Editing then slider:FinishEditing(true) end
			slider:SetValue(slider.Value + direction, true)
		end)
	end
end


function UI.CreateSlider(
	parent,
	title,
	minimum,
	maximum,
	initial,
	suffix,
	callback,
	options
)
	options = options or {}
	local explanations = {
		["Precisão da mira"] = "Baixo corrige menos. Alto mantém a mira mais perto do alvo.",
		["Velocidade da mira"] = "Baixo move devagar. Alto responde mais rápido.",
		["Suavidade da mira"] = "Baixo responde mais rápido. Alto deixa o movimento mais suave.",
		["Área de busca (FOV)"] = "Aumente para procurar jogadores mais longe do centro da tela.",
		["Preferência desta região"] = "Quanto maior, mais vezes a mira tenta usar esta região.",
		["Correção lateral"] = "Força usada para acompanhar o jogador quando ele anda para os lados.",
		["Correção vertical"] = "Força usada para acompanhar o jogador quando ele sobe ou desce.",
		["Tamanho do menu"] = "Aumenta ou diminui o painel inteiro. A alça do canto muda largura e altura separadamente.",
		["Tamanho das opções"] = "Aumenta os cartões e botões sem mudar o tamanho do menu.",
	}

	local card = Util.New("Frame", {
		Size = UDim2.new(1, 0, 0, 100),
		BackgroundColor3 = Theme.Card,
		BackgroundTransparency = 0.04,
		BorderSizePixel = 0,
	}, parent)

	Util.Corner(card, 16)
	Util.Sheen(card, 0.08)
	Util.Stroke(card, Theme.BorderInner, 0.70, 1)

	local titleLabel = Util.FitText(Util.New("TextLabel", {
		Position = UDim2.fromOffset(14, 8),
		Size = UDim2.new(1, options.Help and -132 or -96, 0, 16),
		BackgroundTransparency = 1,
		Text = title,
		TextColor3 = Theme.Text,
		Font = Enum.Font.GothamMedium,
		TextSize = 9,
		TextXAlignment = Enum.TextXAlignment.Left,
	}, card), 7, 10)

	local valueLabel, valueStroke = UI.CreateSliderValueBox(card,
		UDim2.new(1, -14, 0, 4), UDim2.fromOffset(70, 26), Vector2.new(1, 0))

	local descriptionText = options.Description
		or explanations[title]
		or "Mude o valor até encontrar o ajuste que você prefere."
	local descriptionLabel = Util.FitText(Util.New("TextLabel", {
		Position = UDim2.fromOffset(14, 32),
		Size = UDim2.new(1, -28, 0, 16),
		BackgroundTransparency = 1,
		Text = descriptionText,
		TextColor3 = Theme.Sub,
		Font = Enum.Font.Gotham,
		TextSize = 7,
		TextWrapped = true,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Top,
	}, card), 6, 8)

	local hitArea = Util.New("TextButton", {
		AnchorPoint = Vector2.new(0, 1),
		Position = UDim2.new(0, 48, 1, -4),
		Size = UDim2.new(1, -96, 0, 28),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Text = "",
		AutoButtonColor = false,
	}, card)

	local track = Util.New("Frame", {
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.new(0, 4, 0.5, 0),
		Size = UDim2.new(1, -8, 0, 6),
		BackgroundColor3 = Theme.Chip,
		BorderSizePixel = 0,
		Active = true,
	}, hitArea)

	Util.Corner(track, 999)
	Util.Stroke(track, Theme.BorderSoft, 0.62, 1)

	local fill = Util.New("Frame", {
		Size = UDim2.fromScale(0, 1),
		BackgroundColor3 = Theme.Accent,
		BorderSizePixel = 0,
	}, track)

	Util.Corner(fill, 999)
	Util.Gradient(fill, Theme.Accent, Theme.Accent2, 0)

	local thumb = Util.New("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0, 0, 0.5, 0),
		Size = UDim2.fromOffset(16, 16),
		BackgroundColor3 = Theme.Text,
		BorderSizePixel = 0,
		Active = true,
	}, track)

	Util.Corner(thumb, 999)
	Util.Sheen(thumb, 0.01)
	Util.Stroke(thumb, Theme.Accent2, 0.02, 2)

	local decrease = UI.CreateSliderStepButton(card, "−",
		UDim2.new(0, 12, 1, -4), UDim2.fromOffset(28, 28), Vector2.new(0, 1))
	local increase = UI.CreateSliderStepButton(card, "+",
		UDim2.new(1, -12, 1, -4), UDim2.fromOffset(28, 28), Vector2.new(1, 1))

	local slider = {
		Decrease = decrease, Increase = increase, ValueStroke = valueStroke,
		Card = card,
		Title = titleLabel,
		Description = descriptionLabel,
		OriginalDescription = descriptionText,
		Track = track,
		Fill = fill,
		Thumb = thumb,
		Label = valueLabel,
		Min = minimum,
		Max = maximum,
		Suffix = suffix or "",
		Callback = callback,
	}
	if options.Help then
		slider.Help = UI.CreateHelpButton(
			card,
			title,
			options.Help,
			UDim2.new(1, -90, 0, 3)
		)
	end

	UI.BindSliderPrecision(slider)

	local function start(input)
		if not UI.SliderCanInteract(slider) then return end
		if input.UserInputType == Enum.UserInputType.Touch
			or input.UserInputType == Enum.UserInputType.MouseButton1 then
			if UI.ActiveSliderInput
				and UI.ActiveSliderInput ~= input then

				return
			end

			UI.ActiveSlider = slider
			UI.ActiveSliderInput = input

			local width = math.max(track.AbsoluteSize.X, 1)
			local alpha = math.clamp(
				(input.Position.X - track.AbsolutePosition.X) / width,
				0,
				1
			)

			local value =
				minimum + (maximum - minimum) * alpha

			slider:SetValue(value, true)
		end
	end

	hitArea.InputBegan:Connect(start)
	thumb.InputBegan:Connect(start)

	slider:SetValue(initial, false)
	slider.Record = UI.RegisterSharedControl(card, parent, title, 100, options)

	return slider
end

function UI.Section(parent, title, subtitle)
	local box = Util.New("Frame", {
		Size = UDim2.new(1, 0, 0, subtitle and 52 or 30),
		BackgroundColor3 = Theme.Surface2,
		BackgroundTransparency = 0.68,
		BorderSizePixel = 0,
	}, parent)
	Util.Corner(box, 14)
	Util.Stroke(box, Theme.BorderSoft, 0.84, 1)

	local marker = Util.New("Frame", {
		Position = UDim2.fromOffset(8, 8),
		Size = UDim2.new(0, 3, 1, -16),
		BackgroundColor3 = Theme.Accent,
		BorderSizePixel = 0,
	}, box)

	Util.Corner(marker, 999)
	Util.Stroke(marker, Theme.Accent2, 0.50, 2)

	Util.New("TextLabel", {
		Position = UDim2.fromOffset(18, 6),
		Size = UDim2.new(1, -28, 0, 20),
		BackgroundTransparency = 1,
		Text = title,
		TextColor3 = Theme.Text,
		Font = Enum.Font.GothamBold,
		TextSize = 10,
		TextXAlignment = Enum.TextXAlignment.Left,
	}, box)

	if subtitle then
		Util.New("TextLabel", {
			Position = UDim2.fromOffset(18, 27),
			Size = UDim2.new(1, -28, 1, -31),
			BackgroundTransparency = 1,
			Text = subtitle,
			TextColor3 = Theme.Sub,
			Font = Enum.Font.Gotham,
			TextSize = 8,
			TextWrapped = true,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextYAlignment = Enum.TextYAlignment.Top,
		}, box)
	end

	return box
end

function UI.Stack(parent)
	local holder = Util.New("Frame", {
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
	}, parent)

	Util.New("UIListLayout", {
		Padding = UDim.new(0, 9),
		SortOrder = Enum.SortOrder.LayoutOrder,
	}, holder)

	local page = UI.GetPageForObject(holder)
	if page then
		local count = (UI.OrganizerContainerCounts[page] or 0) + 1
		UI.OrganizerContainerCounts[page] = count
		UI.RegisterOrganizerContainer(
			holder,
			page.Name .. ":Stack" .. tostring(count)
		)
	end

	return holder
end

function UI.CreateExpandableGroup(parent, title, subtitle, expandedByDefault)
	local shell = Util.New("Frame", {
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
	}, parent)
	Util.New("UIListLayout", {
		Padding = UDim.new(0, 8),
		SortOrder = Enum.SortOrder.LayoutOrder,
	}, shell)

	local header = Util.New("TextButton", {
		Size = UDim2.new(1, 0, 0, subtitle and 58 or 46),
		BackgroundColor3 = Theme.Surface2,
		BackgroundTransparency = 0.12,
		BorderSizePixel = 0,
		Text = "",
		AutoButtonColor = false,
		LayoutOrder = 1,
	}, shell)
	Util.Corner(header, 15)
	Util.Sheen(header, 0.08)
	Util.Stroke(header, Theme.BorderSoft, 0.58, 1)


	Util.FitText(Util.New("TextLabel", {
		Position = UDim2.fromOffset(20, 6),
		Size = UDim2.new(1, -104, 0, 20),
		BackgroundTransparency = 1,
		Text = title,
		TextColor3 = Theme.Text,
		Font = Enum.Font.GothamBold,
		TextSize = 9,
		TextXAlignment = Enum.TextXAlignment.Left,
	}, header), 7, 10)

	if subtitle then
		Util.FitText(Util.New("TextLabel", {
			Position = UDim2.fromOffset(20, 28),
			Size = UDim2.new(1, -104, 0, 20),
			BackgroundTransparency = 1,
			Text = subtitle,
			TextColor3 = Theme.Sub,
			Font = Enum.Font.Gotham,
			TextSize = 7,
			TextXAlignment = Enum.TextXAlignment.Left,
		}, header), 6, 8)
	end

	local stateLabel = Util.New("TextLabel", {
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -10, 0.5, 0),
		Size = UDim2.fromOffset(66, 25),
		BackgroundColor3 = Theme.Card,
		BackgroundTransparency = 0.06,
		BorderSizePixel = 0,
		Text = "ABRIR",
		TextColor3 = Theme.Accent2,
		Font = Enum.Font.GothamBold,
		TextSize = 7,
	}, header)
	Util.Corner(stateLabel, 999)
	Util.Stroke(stateLabel, Theme.BorderSoft, 0.58, 1)
	UI.TouchFeedback(header)

	local content = Util.New("Frame", {
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.None,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Visible = false,
		LayoutOrder = 2,
	}, shell)
	Util.New("UIListLayout", {
		Padding = UDim.new(0, 9),
		SortOrder = Enum.SortOrder.LayoutOrder,
	}, content)

	local page = UI.GetPageForObject(content)
	if page then
		local count = (UI.OrganizerContainerCounts[page] or 0) + 1
		UI.OrganizerContainerCounts[page] = count
		UI.RegisterOrganizerContainer(
			content,
			page.Name .. ":Advanced" .. tostring(count)
		)
	end

	local group = {
		Shell = shell,
		Header = header,
		Content = content,
		StateLabel = stateLabel,
		Expanded = false,
	}

	function group:SetExpanded(expanded)
		self.Expanded = expanded == true
		self.Content.Visible = self.Expanded
		self.Content.AutomaticSize = self.Expanded
			and Enum.AutomaticSize.Y
			or Enum.AutomaticSize.None
		self.Content.Size = UDim2.new(1, 0, 0, 0)
		self.StateLabel.Text = self.Expanded and "FECHAR" or "ABRIR"
		self.StateLabel.TextColor3 = self.Expanded
			and Theme.Text
			or Theme.Accent2
		task.defer(function()
			local activePage = UI.GetPageForObject(self.Shell)
			if activePage then
				UI.RefreshPageScrollCue(activePage)
			end
		end)
	end

	header.MouseButton1Click:Connect(function()
		group:SetExpanded(not group.Expanded)
	end)
	group:SetExpanded(expandedByDefault == true)
	return content, group
end

--==============================================================
-- GUI CONSTRUCTION
--==============================================================

-- Main responsive three-column interface.
local VISION_MENU_ASPECT = 1.92

function UI.BuildAimStatusPanel(panel)
	State.UI.StatusTitle = Util.FitText(Util.New("TextLabel", {
		Name = "AAP_StatusTitle", Position = UDim2.fromOffset(10, 6),
		Size = UDim2.new(1, -20, 0, 14), BackgroundTransparency = 1,
		Text = "ESTADO DA MIRA", TextColor3 = Theme.Text,
		Font = Enum.Font.GothamBold, TextSize = 7,
		TextXAlignment = Enum.TextXAlignment.Left,
	}, panel), 6, 8)
	-- The title owns the entire first line. State and its dot share a separate line.
	State.UI.StatusDot = Util.New("Frame", {
		Name = "AAP_StatusDot", AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.fromOffset(10, 31), Size = UDim2.fromOffset(6, 6),
		BackgroundColor3 = Theme.Muted, BorderSizePixel = 0,
	}, panel)
	Util.Corner(State.UI.StatusDot, 999)
	State.UI.StatusMini = Util.FitText(Util.New("TextLabel", {
		Name = "AAP_StatusState", Position = UDim2.fromOffset(23, 23),
		Size = UDim2.new(1, -33, 0, 16), BackgroundTransparency = 1,
		Text = "DESATIVADA", TextColor3 = Theme.Sub,
		Font = Enum.Font.GothamMedium, TextSize = 7,
		TextXAlignment = Enum.TextXAlignment.Left,
	}, panel), 6, 8)
	State.UI.Status = Util.FitText(Util.New("TextLabel", {
		Name = "AAP_StatusDescription", Position = UDim2.fromOffset(10, 44),
		Size = UDim2.new(1, -20, 0, 29), BackgroundTransparency = 1,
		Text = "Mira desativada", TextColor3 = Theme.Sub,
		Font = Enum.Font.Gotham, TextSize = 7, TextWrapped = true,
		TextTruncate = Enum.TextTruncate.AtEnd,
		TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Top,
	}, panel), 6, 8)
	State.UI.FPSLabel = Util.FitText(Util.New("TextLabel", {
		Position = UDim2.fromOffset(10, 82), Size = UDim2.new(0.46, -12, 0, 10),
		BackgroundTransparency = 1, Text = "FPS: --", TextColor3 = Theme.Sub,
		Font = Enum.Font.Code, TextSize = 6, TextXAlignment = Enum.TextXAlignment.Left,
	}, panel), 5, 7)
	State.UI.PingLabel = Util.FitText(Util.New("TextLabel", {
		Position = UDim2.new(0.46, 0, 0, 82), Size = UDim2.new(0.54, -10, 0, 10),
		BackgroundTransparency = 1, Text = "PING: --", TextColor3 = Theme.Sub,
		Font = Enum.Font.Code, TextSize = 6, TextXAlignment = Enum.TextXAlignment.Right,
	}, panel), 5, 7)
end

local function GetVisionMenuSize(fill, requestedScale)
	local viewport =
		S.Camera and S.Camera.ViewportSize
		or Vector2.new(800, 450)
	local scale = math.clamp(
		Persistence.FiniteNumber(
			requestedScale ~= nil and requestedScale or Config.MenuScale,
			1
		),
		MENU_SCALE_MIN,
		MENU_SCALE_MAX
	)
	local edge = 8
	local availableWidth = math.max(viewport.X - edge * 2, 1)
	local availableHeight = math.max(viewport.Y - edge * 2, 1)
	local height = math.min(
		availableHeight * (fill or 0.92) * scale,
		availableHeight * 0.985,
		820
	)
	local width = math.min(
		height * VISION_MENU_ASPECT,
		availableWidth * 0.98,
		1500
	)

	height = width / VISION_MENU_ASPECT

	return UDim2.fromOffset(
		math.floor(width + 0.5),
		math.floor(height + 0.5)
	)
end

local function BuildVisionRootUI()
	for _, name in ipairs({
		"AimAssistProV33",
		"AimAssistProV32",
		"AimAssistPro_V32_MobileUI",
		"AimAssistProV31",
		"AimAssistProV30",
		"AimAssistProV29",
		"AimAssistProV28",
		"AimAssistProV27",
		"AimAssistProV26",
		"AimAssistProV25",
		"AimAssistProV24",
		"AimAssistProV23",
		"AimAssistProV22",
	}) do
		while true do
			local old = S.PlayerGui:FindFirstChild(name)
			if not old then
				break
			end

			local cleanupEvent = old:FindFirstChild("AAP_Cleanup")
			if cleanupEvent and cleanupEvent:IsA("BindableEvent") then
				pcall(function()
					cleanupEvent:Fire()
				end)
			end
			old:Destroy()
		end
	end

	local root = Util.New("ScreenGui", {
		Name = "AimAssistProV33",
		ResetOnSpawn = false,
		IgnoreGuiInset = true,
		DisplayOrder = 1000000,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
	}, S.PlayerGui)

	State.UI.Root = root
	State.UI.LayoutEditMode = false
	State.UI.CleanupEvent = Util.New("BindableEvent", {
		Name = "AAP_Cleanup",
	}, root)

	State.UI.FOV = Util.New("Frame", {
		Name = "FOV",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		BackgroundTransparency = 1,
		ZIndex = 1,
	}, root)
	Util.Corner(State.UI.FOV, 999)
	State.UI.FOVStroke = Util.Stroke(State.UI.FOV, Theme.Accent, 0.18, 2)

	do
		local fovInner = Util.New("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromScale(0.70, 0.70),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			ZIndex = 1,
		}, State.UI.FOV)
		Util.Corner(fovInner, 999)
		local fovInnerStroke = Util.Stroke(fovInner, Theme.Accent, 0.26, 1)

		local fovHorizontal = Util.New("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.new(0.32, 0, 0, 1),
			BackgroundColor3 = Theme.Accent,
			BackgroundTransparency = 0.24,
			BorderSizePixel = 0,
			ZIndex = 2,
		}, State.UI.FOV)

		local fovVertical = Util.New("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.new(0, 1, 0.32, 0),
			BackgroundColor3 = Theme.Accent,
			BackgroundTransparency = 0.24,
			BorderSizePixel = 0,
			ZIndex = 2,
		}, State.UI.FOV)

		local fovDot = Util.New("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromOffset(5, 5),
			BackgroundColor3 = Theme.Accent,
			BorderSizePixel = 0,
			ZIndex = 3,
		}, State.UI.FOV)
		Util.Corner(fovDot, 999)
		Util.Stroke(fovDot, Theme.Text, 0.22, 1)

		local fovTicks = {}
		local tickData = {
			{UDim2.new(0.5, 0, 0, 3), UDim2.fromOffset(2, 12)},
			{UDim2.new(1, -3, 0.5, 0), UDim2.fromOffset(12, 2)},
			{UDim2.new(0.5, 0, 1, -3), UDim2.fromOffset(2, 12)},
			{UDim2.new(0, 3, 0.5, 0), UDim2.fromOffset(12, 2)},
		}
		for _, data in ipairs(tickData) do
			local tick = Util.New("Frame", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = data[1],
				Size = data[2],
				BackgroundColor3 = Theme.Accent,
				BackgroundTransparency = 0.16,
				BorderSizePixel = 0,
				ZIndex = 2,
			}, State.UI.FOV)
			Util.Corner(tick, 999)
			fovTicks[#fovTicks + 1] = tick
		end

		State.UI.FOVElements = {
			Inner = fovInner,
			InnerStroke = fovInnerStroke,
			Horizontal = fovHorizontal,
			Vertical = fovVertical,
			Dot = fovDot,
			Ticks = fovTicks,
			Lines = {fovHorizontal, fovVertical},
		}
		UI.ApplyFOVStyle(Config.FOVStyle)
	end

	local main = Util.New("Frame", {
		Name = "Main",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.52),
		Size = GetVisionMenuSize(0.84),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ClipsDescendants = false,
		Active = true,
		ZIndex = 2,
	}, root)
	State.UI.Main = main
	Util.Corner(main, 20)

	State.UI.MainSizeConstraint = Util.New("UISizeConstraint", {
		MinSize = Vector2.new(560, 260),
		MaxSize = Vector2.new(1500, 820),
	}, main)

	local mainShadow = Util.New("Frame", {
		Name = "DeepShadow",
		Position = UDim2.fromOffset(3, 5),
		Size = UDim2.new(1, -6, 1, -8),
		BackgroundColor3 = Color3.fromRGB(0, 0, 0),
		BackgroundTransparency = 0.34,
		BorderSizePixel = 0,
		ZIndex = 1,
	}, main)
	Util.Corner(mainShadow, 22)

	local mainHalo = Util.New("Frame", {
		Name = "CrimsonHalo",
		Position = UDim2.fromOffset(3, 3),
		Size = UDim2.new(1, -6, 1, -6),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ZIndex = 4,
	}, main)
	Util.Corner(mainHalo, 17)
	Util.Stroke(mainHalo, Theme.AccentHot, 0.70, 3)

	local shellBorder = Util.New("Frame", {
		Name = "ShellBorder",
		Position = UDim2.fromOffset(1, 1),
		Size = UDim2.new(1, -2, 1, -2),
		BackgroundColor3 = Theme.Border,
		BackgroundTransparency = 0.08,
		BorderSizePixel = 0,
		ZIndex = 2,
	}, main)
	Util.Corner(shellBorder, 20)
	Util.Stroke(shellBorder, Theme.Accent, 0.12, 1)

	local innerSurface = Util.New("Frame", {
		Name = "InnerSurface",
		Position = UDim2.fromOffset(2, 2),
		Size = UDim2.new(1, -4, 1, -4),
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		BorderSizePixel = 0,
		ClipsDescendants = true,
		ZIndex = 3,
	}, main)
	Util.Corner(innerSurface, 18)
	Util.GlassGradient(
		innerSurface,
		Color3.fromRGB(14, 14, 22),
		Theme.BG,
		0.04,
		0.01,
		90
	)

	local header = Util.New("Frame", {
		Name = "Header",
		Position = UDim2.fromOffset(3, 3),
		Size = UDim2.new(1, -6, 0, 52),
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		BorderSizePixel = 0,
		ClipsDescendants = true,
		ZIndex = 5,
	}, innerSurface)
	State.UI.Header = header
	Util.Corner(header, 16)
	Util.GlassGradient(
		header,
		Color3.fromRGB(28, 29, 38),
		Color3.fromRGB(15, 17, 24),
		0.02,
		0.04,
		90
	)
	Util.Stroke(header, Theme.BorderInner, 0.62, 1)
	Util.InnerHighlight(header, 14, 0.88, 6)

	Util.New("Frame", {
		Position = UDim2.new(0, 10, 1, -1),
		Size = UDim2.new(1, -20, 0, 1),
		BackgroundColor3 = Theme.BorderSoft,
		BorderSizePixel = 0,
		ZIndex = 6,
	}, header)

	local logoMark = Util.New("Frame", {
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.new(0, 10, 0.5, 0),
		Size = UDim2.fromOffset(30, 30),
		BackgroundColor3 = Theme.AccentSoft,
		BorderSizePixel = 0,
		ZIndex = 7,
	}, header)
	Util.Corner(logoMark, 10)
	Util.Stroke(logoMark, Theme.Accent2, 0.12, 1)
	Util.Sheen(logoMark, 0.06)

	Util.New("TextLabel", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		Text = "V",
		TextColor3 = Theme.Accent2,
		Font = Enum.Font.GothamBlack,
		TextSize = 15,
		ZIndex = 8,
	}, logoMark)

	Util.FitText(Util.New("TextLabel", {
		Position = UDim2.fromOffset(48, 8),
		Size = UDim2.new(0.16, -54, 0, 17),
		BackgroundTransparency = 1,
		Text = "VISION X",
		TextColor3 = Theme.Text,
		Font = Enum.Font.GothamBlack,
		TextSize = 10,
		TextXAlignment = Enum.TextXAlignment.Left,
		ZIndex = 7,
	}, header), 7, 11)

	Util.FitText(Util.New("TextLabel", {
		Position = UDim2.fromOffset(48, 28),
		Size = UDim2.new(0.16, -54, 0, 12),
		BackgroundTransparency = 1,
		Text = "CONTROLE NO CELULAR",
		TextColor3 = Theme.Sub,
		Font = Enum.Font.GothamBold,
		TextSize = 7,
		TextXAlignment = Enum.TextXAlignment.Left,
		ZIndex = 7,
	}, header), 6, 8)

	State.UI.HeaderDragArea = Util.New("TextButton", {
		Position = UDim2.fromOffset(0, 0),
		Size = UDim2.new(0.16, 0, 1, -1),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Text = "",
		AutoButtonColor = false,
		Active = true,
		ZIndex = 9,
	}, header)

	State.UI.NavHolder = Util.New("Frame", {
		Position = UDim2.new(0.16, 2, 0, 6),
		Size = UDim2.new(0.71, -4, 1, -12),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ZIndex = 7,
	}, header)

	Util.New("UIGridLayout", {
		CellSize = UDim2.new(1 / 6, -4, 1, 0),
		CellPadding = UDim2.fromOffset(4, 0),
		FillDirectionMaxCells = 6,
		SortOrder = Enum.SortOrder.LayoutOrder,
	}, State.UI.NavHolder)

	local windowControls = Util.New("Frame", {
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -8, 0.5, 0),
		Size = UDim2.new(0.12, 0, 0, 34),
		BackgroundColor3 = Theme.Surface2,
		BorderSizePixel = 0,
		ZIndex = 7,
	}, header)
	Util.Corner(windowControls, 999)
	Util.Sheen(windowControls, 0.10)
	Util.Stroke(windowControls, Theme.BorderSoft, 0.55, 1)
	Util.New("UIGridLayout", {
		CellSize = UDim2.new(1 / 3, 0, 1, 0),
		FillDirectionMaxCells = 3,
		SortOrder = Enum.SortOrder.LayoutOrder,
	}, windowControls)

	local function windowButton(textValue, order)
		local button = Util.New("TextButton", {
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Text = textValue,
			TextColor3 = Theme.Sub,
			Font = Enum.Font.GothamBold,
			TextSize = 11,
			AutoButtonColor = false,
			LayoutOrder = order,
			ZIndex = 8,
		}, windowControls)
		UI.TouchFeedback(button)
		return button
	end

	State.UI.Minimize = windowButton("-", 1)
	State.UI.Maximize = windowButton("+", 2)
	State.UI.Close = windowButton("X", 3)

	local bodyTop = 58
	local footerHeight = 32
	local bodyBottom = footerHeight + 6

	local left = Util.New("ScrollingFrame", {
		Position = UDim2.fromOffset(5, bodyTop),
		Size = UDim2.new(0.18, -7, 1, -(bodyTop + bodyBottom)),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		CanvasSize = UDim2.fromOffset(0, 344),
		ScrollBarThickness = 2,
		ScrollBarImageColor3 = Theme.Accent,
		ScrollBarImageTransparency = 0.35,
		ScrollingDirection = Enum.ScrollingDirection.Y,
		ElasticBehavior = Enum.ElasticBehavior.WhenScrollable,
		ClipsDescendants = true,
		ZIndex = 4,
	}, innerSurface)
	State.UI.LeftRail = left

	local center = Util.New("Frame", {
		Position = UDim2.new(0.18, 3, 0, bodyTop),
		Size = UDim2.new(0.64, -6, 1, -(bodyTop + bodyBottom)),
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		BorderSizePixel = 0,
		ClipsDescendants = true,
		ZIndex = 4,
	}, innerSurface)
	State.UI.Content = center
	Util.Corner(center, 15)
	Util.GlassGradient(
		center,
		Color3.fromRGB(18, 20, 28),
		Color3.fromRGB(8, 10, 15),
		0.04,
		0.02,
		90
	)
	Util.Stroke(center, Theme.BorderInner, 0.60, 1)
	Util.InnerHighlight(center, 14, 0.90, 5)

	State.UI.PageHost = Util.New("Frame", {
		Position = UDim2.fromOffset(12, 11),
		Size = UDim2.new(1, -24, 1, -22),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ZIndex = 5,
	}, center)

	local right = Util.New("ScrollingFrame", {
		Position = UDim2.new(0.82, 2, 0, bodyTop),
		Size = UDim2.new(0.18, -7, 1, -(bodyTop + bodyBottom)),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		CanvasSize = UDim2.fromOffset(0, 492),
		ScrollBarThickness = 2,
		ScrollBarImageColor3 = Theme.Accent,
		ScrollBarImageTransparency = 0.35,
		ScrollingDirection = Enum.ScrollingDirection.Y,
		ElasticBehavior = Enum.ElasticBehavior.WhenScrollable,
		ClipsDescendants = true,
		ZIndex = 4,
	}, innerSurface)
	State.UI.RightRail = right

	local function panel(parent, position, size)
		local frame = Util.New("Frame", {
			Position = position,
			Size = size,
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			BorderSizePixel = 0,
			ClipsDescendants = true,
		}, parent)
		Util.Corner(frame, 14)
		Util.GlassGradient(
			frame,
			Color3.fromRGB(22, 24, 32),
			Color3.fromRGB(10, 12, 18),
			0.05,
			0.02,
			90
		)
		Util.Stroke(frame, Theme.BorderInner, 0.64, 1)
		Util.InnerHighlight(frame, 10, 0.91)
		return frame
	end

	local statusPanel = panel(left, UDim2.fromOffset(4, 3), UDim2.new(1, -10, 0, 96))
	UI.BuildAimStatusPanel(statusPanel)

	State.UI.LeftToggleHolder = panel(
		left,
		UDim2.fromOffset(4, 105),
		UDim2.new(1, -10, 0, 142)
	)

	local profilePanel = panel(
		left,
		UDim2.fromOffset(4, 253),
		UDim2.new(1, -10, 0, 72)
	)
	Util.New("TextLabel", {
		Position = UDim2.fromOffset(9, 5),
		Size = UDim2.new(1, -18, 0, 15),
		BackgroundTransparency = 1,
		Text = "PERFIL ATUAL",
		TextColor3 = Theme.Text,
		Font = Enum.Font.GothamBold,
		TextSize = 7,
		TextXAlignment = Enum.TextXAlignment.Left,
	}, profilePanel)

	local profileChip = Util.New("Frame", {
		Position = UDim2.fromOffset(6, 23),
		Size = UDim2.new(1, -12, 0, 42),
		BackgroundColor3 = Theme.Card,
		BorderSizePixel = 0,
	}, profilePanel)
	Util.Corner(profileChip, 11)
	Util.Stroke(profileChip, Theme.BorderInner, 0.68, 1)
	Util.Sheen(profileChip, 0.08)
	local profileMarker = Util.New("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0, 13, 0.5, 0),
		Size = UDim2.fromOffset(8, 8),
		BackgroundColor3 = Theme.Accent,
		BorderSizePixel = 0,
	}, profileChip)
	Util.Corner(profileMarker, 999)

	State.UI.CurrentProfileLabel = Util.New("TextLabel", {
		Position = UDim2.fromOffset(25, 7),
		Size = UDim2.new(1, -32, 0, 13),
		BackgroundTransparency = 1,
		Text = "EQUILIBRADO",
		TextColor3 = Theme.Text,
		Font = Enum.Font.GothamBold,
		TextSize = 7,
		TextXAlignment = Enum.TextXAlignment.Left,
	}, profileChip)
	Util.FitText(State.UI.CurrentProfileLabel, 5, 9)

	State.UI.CurrentWeaponLabel = Util.New("TextLabel", {
		Position = UDim2.fromOffset(25, 23),
		Size = UDim2.new(1, -32, 0, 12),
		BackgroundTransparency = 1,
		Text = "RIFLE",
		TextColor3 = Theme.Sub,
		Font = Enum.Font.Gotham,
		TextSize = 6,
		TextXAlignment = Enum.TextXAlignment.Left,
	}, profileChip)
	Util.FitText(State.UI.CurrentWeaponLabel, 5, 8)

	local playersPanel = panel(
		right,
		UDim2.fromOffset(4, 3),
		UDim2.new(1, -10, 0, 250)
	)
	Util.New("TextLabel", {
		Position = UDim2.fromOffset(9, 7),
		Size = UDim2.new(1, -18, 0, 16),
		BackgroundTransparency = 1,
		Text = "JOGADORES",
		TextColor3 = Theme.Text,
		Font = Enum.Font.GothamBold,
		TextSize = 7,
		TextXAlignment = Enum.TextXAlignment.Left,
	}, playersPanel)

	State.UI.TargetSearch = Util.New("TextBox", {
		Position = UDim2.fromOffset(7, 28),
		Size = UDim2.new(1, -14, 0, 30),
		BackgroundColor3 = Theme.Card,
		BackgroundTransparency = 0.05,
		BorderSizePixel = 0,
		PlaceholderText = "Buscar jogador",
		PlaceholderColor3 = Theme.Dim,
		Text = "",
		TextColor3 = Theme.Text,
		Font = Enum.Font.Gotham,
		TextSize = 7,
		TextXAlignment = Enum.TextXAlignment.Left,
		ClearTextOnFocus = false,
	}, playersPanel)
	Util.Corner(State.UI.TargetSearch, 11)
	Util.Stroke(State.UI.TargetSearch, Theme.BorderSoft, 0.56, 1)
	Util.Sheen(State.UI.TargetSearch, 0.10)
	Util.New("UIPadding", {
		PaddingLeft = UDim.new(0, 8),
		PaddingRight = UDim.new(0, 8),
	}, State.UI.TargetSearch)

	State.UI.TargetList = Util.New("ScrollingFrame", {
		Position = UDim2.fromOffset(7, 64),
		Size = UDim2.new(1, -14, 1, -71),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		CanvasSize = UDim2.new(),
		ScrollBarThickness = 2,
		ScrollBarImageColor3 = Theme.Accent,
		ScrollingDirection = Enum.ScrollingDirection.Y,
		ElasticBehavior = Enum.ElasticBehavior.WhenScrollable,
	}, playersPanel)
	local targetLayout = Util.New("UIListLayout", {
		Padding = UDim.new(0, 4),
		SortOrder = Enum.SortOrder.LayoutOrder,
	}, State.UI.TargetList)
	Util.New("UIPadding", {
		PaddingLeft = UDim.new(0, 2),
		PaddingRight = UDim.new(0, 4),
		PaddingTop = UDim.new(0, 2),
		PaddingBottom = UDim.new(0, 3),
	}, State.UI.TargetList)
	targetLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		if State.UI.TargetList and State.UI.TargetList.Parent then
			State.UI.TargetList.CanvasSize =
				UDim2.fromOffset(0, targetLayout.AbsoluteContentSize.Y + 6)
		end
	end)

	local teamsPanel = panel(
		right,
		UDim2.fromOffset(4, 261),
		UDim2.new(1, -10, 0, 120)
	)
	Util.New("TextLabel", {
		Position = UDim2.fromOffset(9, 7),
		Size = UDim2.new(1, -18, 0, 16),
		BackgroundTransparency = 1,
		Text = "PROTEGIDOS",
		TextColor3 = Theme.Text,
		Font = Enum.Font.GothamBold,
		TextSize = 7,
		TextXAlignment = Enum.TextXAlignment.Left,
	}, teamsPanel)
	State.UI.TeamList = Util.New("ScrollingFrame", {
		Position = UDim2.fromOffset(8, 28),
		Size = UDim2.new(1, -16, 1, -35),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		CanvasSize = UDim2.new(),
		ScrollBarThickness = 2,
		ScrollBarImageColor3 = Theme.Accent,
		ScrollingDirection = Enum.ScrollingDirection.Y,
		ElasticBehavior = Enum.ElasticBehavior.WhenScrollable,
	}, teamsPanel)
	local teamLayout = Util.New("UIListLayout", {
		Padding = UDim.new(0, 4),
		SortOrder = Enum.SortOrder.LayoutOrder,
	}, State.UI.TeamList)
	teamLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		if State.UI.TeamList and State.UI.TeamList.Parent then
			State.UI.TeamList.CanvasSize =
				UDim2.fromOffset(0, teamLayout.AbsoluteContentSize.Y + 2)
		end
	end)

	local infoPanel = panel(
		right,
		UDim2.fromOffset(4, 389),
		UDim2.new(1, -10, 0, 96)
	)
	Util.New("TextLabel", {
		Position = UDim2.fromOffset(9, 7),
		Size = UDim2.new(1, -18, 0, 16),
		BackgroundTransparency = 1,
		Text = "GUIA RÁPIDO",
		TextColor3 = Theme.Text,
		Font = Enum.Font.GothamBold,
		TextSize = 7,
		TextXAlignment = Enum.TextXAlignment.Left,
	}, infoPanel)
	State.UI.InfoStatus = Util.New("TextLabel", {
		Position = UDim2.fromOffset(9, 29),
		Size = UDim2.new(1, -18, 1, -36),
		BackgroundTransparency = 1,
		Text = "FOCAR: escolhe o alvo\nPROTEGER: não entra na mira\nCORPO: escolhe onde mirar",
		TextColor3 = Theme.Sub,
		Font = Enum.Font.Code,
		TextSize = 7,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Top,
	}, infoPanel)

	local footer = Util.New("Frame", {
		Position = UDim2.new(0, 5, 1, -(footerHeight + 3)),
		Size = UDim2.new(1, -10, 0, footerHeight),
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		BorderSizePixel = 0,
		ClipsDescendants = true,
		ZIndex = 4,
	}, innerSurface)
	State.UI.Footer = footer
	Util.Corner(footer, 15)
	Util.GlassGradient(
		footer,
		Color3.fromRGB(22, 19, 25),
		Color3.fromRGB(10, 11, 16),
		0.04,
		0.02,
		0
	)
	Util.Stroke(footer, Theme.BorderInner, 0.62, 1)
	Util.InnerHighlight(footer, 14, 0.91, 5)

	Util.New("TextLabel", {
		Position = UDim2.fromOffset(14, 0),
		Size = UDim2.new(0.75, -18, 1, 0),
		BackgroundTransparency = 1,
		Text = "Arraste o topo para mover  •  Arraste o canto para redimensionar",
		TextColor3 = Theme.Sub,
		Font = Enum.Font.GothamMedium,
		TextSize = 7,
		TextXAlignment = Enum.TextXAlignment.Left,
	}, footer)

	local footerBrand = Util.New("Frame", {
		Position = UDim2.fromScale(0.80, 0),
		Size = UDim2.new(0.20, -40, 1, 0),
		BackgroundColor3 = Theme.AccentDeep,
		BackgroundTransparency = 0.16,
		BorderSizePixel = 0,
	}, footer)
	Util.Gradient(footerBrand, Theme.AccentDeep, Theme.Surface2, 0)
	Util.New("TextLabel", {
		Size = UDim2.new(1, 0, 0.62, 0),
		BackgroundTransparency = 1,
		Text = "VISION X",
		TextColor3 = Theme.Accent,
		Font = Enum.Font.GothamBlack,
		TextSize = 8,
	}, footerBrand)
	Util.New("TextLabel", {
		Position = UDim2.fromScale(0, 0.55),
		Size = UDim2.fromScale(1, 0.35),
		BackgroundTransparency = 1,
		Text = "FEITO PARA CELULAR",
		TextColor3 = Theme.Sub,
		Font = Enum.Font.GothamBold,
		TextSize = 6,
	}, footerBrand)

	State.UI.ResizeHandle = Util.New("TextButton", {
		Name = "ResizeHandle",
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -3, 0.5, 0),
		Size = UDim2.fromOffset(26, 26),
		BackgroundColor3 = Theme.Surface3,
		BackgroundTransparency = 0.68,
		BorderSizePixel = 0,
		Text = "",
		AutoButtonColor = false,
		Active = true,
		ClipsDescendants = true,
		ZIndex = 18,
	}, footer)
	Util.Corner(State.UI.ResizeHandle, 11)
	Util.Sheen(State.UI.ResizeHandle, 0.28)
	Util.Stroke(State.UI.ResizeHandle, Theme.BorderSoft, 0.52, 1)

	for index = 1, 2 do
		local gripBar = Util.New("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = index == 1
				and UDim2.new(0.5, -2, 0.5, 2)
				or UDim2.new(0.5, 4, 0.5, 4),
			Size = UDim2.fromOffset(index == 1 and 15 or 8, 2),
			Rotation = -45,
			BackgroundColor3 = index == 1 and Theme.Accent or Theme.Accent2,
			BackgroundTransparency = index == 1 and 0.30 or 0.48,
			BorderSizePixel = 0,
			ZIndex = 19,
		}, State.UI.ResizeHandle)
		Util.Corner(gripBar, 999)
	end
	UI.TouchFeedback(State.UI.ResizeHandle)

	State.UI.CompactBar = Util.New("Frame", {
		Name = "CompactBar",
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.fromScale(0.5, 0.09),
		Size = UDim2.fromScale(0.30, 0.08),
		BackgroundColor3 = Theme.Border,
		BackgroundTransparency = 0.08,
		BorderSizePixel = 0,
		ClipsDescendants = true,
		Visible = false,
		Active = true,
		ZIndex = 30,
	}, root)
	Util.Corner(State.UI.CompactBar, 999)
	Util.Stroke(State.UI.CompactBar, Theme.Accent, 0.18, 1)
	local compactHalo = Util.New("Frame", {
		Name = "CompactHalo",
		Position = UDim2.fromOffset(3, 3),
		Size = UDim2.new(1, -6, 1, -6),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ZIndex = 34,
	}, State.UI.CompactBar)
	Util.Corner(compactHalo, 999)
	Util.Stroke(compactHalo, Theme.AccentHot, 0.76, 3)
	Util.New("UIAspectRatioConstraint", {
		AspectRatio = 6.20,
		DominantAxis = Enum.DominantAxis.Width,
	}, State.UI.CompactBar)
	Util.New("UISizeConstraint", {
		MinSize = Vector2.new(280, 46),
		MaxSize = Vector2.new(480, 78),
	}, State.UI.CompactBar)

	local compactSurface = Util.New("Frame", {
		Name = "Surface",
		Position = UDim2.fromOffset(2, 2),
		Size = UDim2.new(1, -4, 1, -4),
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		BorderSizePixel = 0,
		ZIndex = 31,
	}, State.UI.CompactBar)
	Util.Corner(compactSurface, 999)
	Util.GlassGradient(
		compactSurface,
		Color3.fromRGB(27, 23, 31),
		Color3.fromRGB(10, 11, 16),
		0.03,
		0.01,
		90
	)
	Util.InnerHighlight(compactSurface, 12, 0.88, 32)

	State.UI.CompactStatus = Util.New("TextLabel", {
		Position = UDim2.fromScale(0.05, 0.14),
		Size = UDim2.fromScale(0.70, 0.30),
		BackgroundTransparency = 1,
		Text = "VISION X | MENU",
		TextColor3 = Theme.Text,
		Font = Enum.Font.GothamBold,
		TextSize = 8,
		TextXAlignment = Enum.TextXAlignment.Left,
		ZIndex = 33,
	}, State.UI.CompactBar)

	State.UI.CompactSub = Util.New("TextLabel", {
		Position = UDim2.fromScale(0.05, 0.49),
		Size = UDim2.fromScale(0.70, 0.25),
		BackgroundTransparency = 1,
		Text = "Mira desativada",
		TextColor3 = Theme.Sub,
		Font = Enum.Font.Gotham,
		TextSize = 7,
		TextXAlignment = Enum.TextXAlignment.Left,
		ZIndex = 33,
	}, State.UI.CompactBar)

	State.UI.CompactDragArea = Util.New("TextButton", {
		Size = UDim2.fromScale(0.75, 1),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Text = "",
		AutoButtonColor = false,
		Active = true,
		ZIndex = 34,
	}, State.UI.CompactBar)

	State.UI.CompactOpen = Util.New("TextButton", {
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -5, 0.5, 0),
		Size = UDim2.new(0.22, 0, 1, -12),
		BackgroundColor3 = Theme.Accent,
		BackgroundTransparency = 0.02,
		BorderSizePixel = 0,
		Text = "ABRIR",
		TextColor3 = Color3.fromRGB(255, 255, 255),
		Font = Enum.Font.GothamBlack,
		TextSize = 10,
		TextStrokeColor3 = Theme.AccentDeep,
		TextStrokeTransparency = 0.32,
		AutoButtonColor = false,
		ZIndex = 35,
	}, State.UI.CompactBar)
	Util.Corner(State.UI.CompactOpen, 999)
	Util.InnerHighlight(State.UI.CompactOpen, 12, 0.55, 36)
	Util.Stroke(State.UI.CompactOpen, Theme.Accent2, 0.04, 2)
	UI.TouchFeedback(State.UI.CompactOpen)

	-- Optional two-button mobile support bar. The AIM button is also the drag
	-- surface while unlocked; the adjacent FIXO button locks its position.
	State.UI.MobileQuickControls = Util.New("Frame", {
		Name = "MobileQuickControls",
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.new(0, 16, 0.62, 0),
		Size = UDim2.fromOffset(124, 44),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ClipsDescendants = false,
		Visible = Config.MobileQuickControls,
		Active = true,
		ZIndex = 40,
	}, root)

	State.UI.MobileAimButton = Util.New("TextButton", {
		Position = UDim2.fromOffset(2, 2),
		Size = UDim2.fromOffset(72, 40),
		BackgroundColor3 = Theme.Card,
		BorderSizePixel = 0,
		Text = "MIRA DESL.",
		TextColor3 = Theme.Text,
		Font = Enum.Font.GothamBold,
		TextSize = 8,
		AutoButtonColor = false,
		Active = true,
		ZIndex = 41,
	}, State.UI.MobileQuickControls)
	Util.Corner(State.UI.MobileAimButton, 999)
	Util.Sheen(State.UI.MobileAimButton, 0.06)
	State.UI.MobileAimStroke =
		Util.Stroke(
			State.UI.MobileAimButton,
			Theme.BorderSoft,
			0.28,
			1
		)
	UI.TouchFeedback(State.UI.MobileAimButton)

	State.UI.MobileLockButton = Util.New("TextButton", {
		Position = UDim2.fromOffset(80, 2),
		Size = UDim2.fromOffset(42, 40),
		BackgroundColor3 = Theme.Card,
		BorderSizePixel = 0,
		Text = "FIXO",
		TextColor3 = Theme.Sub,
		Font = Enum.Font.GothamBold,
		TextSize = 7,
		AutoButtonColor = false,
		Active = true,
		ZIndex = 41,
	}, State.UI.MobileQuickControls)
	Util.Corner(State.UI.MobileLockButton, 999)
	Util.Sheen(State.UI.MobileLockButton, 0.08)
	State.UI.MobileLockStroke =
		Util.Stroke(
			State.UI.MobileLockButton,
			Theme.BorderSoft,
			0.28,
			1
		)
	UI.TouchFeedback(State.UI.MobileLockButton)
	State.UI.MobileQuickDragArea = State.UI.MobileAimButton

	State.UI.DebugOverlay = Util.New("Frame", {
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -12, 0, 12),
		Size = UDim2.fromOffset(240, 148),
		BackgroundColor3 = Color3.new(1, 1, 1),
		BackgroundTransparency = 0.04,
		BorderSizePixel = 0,
		Visible = false,
		ZIndex = 20,
	}, root)
	Util.Corner(State.UI.DebugOverlay, 14)
	Util.GlassGradient(
		State.UI.DebugOverlay,
		Theme.GlassRaised,
		Theme.Glass,
		0.03,
		0.08,
		90
	)
	Util.Stroke(State.UI.DebugOverlay, Theme.BorderInner, 0.52, 1)
	Util.InnerHighlight(State.UI.DebugOverlay, 1, 0.86, 21)
	Util.New("TextLabel", {
		Position = UDim2.fromOffset(10, 7),
		Size = UDim2.new(1, -20, 0, 18),
		BackgroundTransparency = 1,
		Text = "DIAGNÓSTICO",
		TextColor3 = Theme.Text,
		Font = Enum.Font.GothamBold,
		TextSize = 8,
		TextXAlignment = Enum.TextXAlignment.Left,
		ZIndex = 21,
	}, State.UI.DebugOverlay)
	State.UI.DebugText = Util.New("TextLabel", {
		Position = UDim2.fromOffset(10, 29),
		Size = UDim2.new(1, -20, 1, -37),
		BackgroundTransparency = 1,
		Text = "",
		TextColor3 = Theme.Sub,
		Font = Enum.Font.Code,
		TextSize = 7,
		TextWrapped = true,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Top,
		ZIndex = 21,
	}, State.UI.DebugOverlay)

	State.UI.DebugLine = Util.New("Frame", {
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromOffset(0, 1),
		BackgroundColor3 = Theme.Accent,
		BorderSizePixel = 0,
		Visible = false,
		ZIndex = 2,
	}, root)

	State.UI.UpdateResponsiveLayout = function()
		if not main.Parent then
			return
		end

		local preset = MENU_LAYOUT_PRESETS[Config.MenuLayoutStyle]
			or MENU_LAYOUT_PRESETS.BALANCED
		local narrow = main.AbsoluteSize.X > 0
			and main.AbsoluteSize.X < 720
		local leftWidth = preset.Left
		local rightWidth = preset.Right

		if narrow and leftWidth > 0 then
			rightWidth = 0
			leftWidth = math.clamp(leftWidth, 0.20, 0.23)
		end

		local centerWidth = math.max(1 - leftWidth - rightWidth, 0.48)
		local hasLeft = leftWidth > 0.01
		local hasRight = rightWidth > 0.01
		State.UI.LeftRail.Visible = hasLeft
		State.UI.RightRail.Visible = hasRight

		if hasLeft then
			State.UI.LeftRail.Position = UDim2.fromOffset(5, bodyTop)
			State.UI.LeftRail.Size = UDim2.new(
				leftWidth,
				-7,
				1,
				-(bodyTop + bodyBottom)
			)
		end

		State.UI.Content.Position = UDim2.new(
			leftWidth,
			hasLeft and 3 or 5,
			0,
			bodyTop
		)
		State.UI.Content.Size = UDim2.new(
			centerWidth,
			hasRight and -6 or -8,
			1,
			-(bodyTop + bodyBottom)
		)

		if hasRight then
			State.UI.RightRail.Position = UDim2.new(
				leftWidth + centerWidth,
				2,
				0,
				bodyTop
			)
			State.UI.RightRail.Size = UDim2.new(
				rightWidth,
				-7,
				1,
				-(bodyTop + bodyBottom)
			)
		end
	end

	State.UI.ApplyMenuLayoutStyle = function(styleName)
		Config.MenuLayoutStyle = MENU_LAYOUT_PRESETS[styleName]
			and styleName
			or "BALANCED"
		State.UI.UpdateResponsiveLayout()
		return Config.MenuLayoutStyle
	end

	Runtime.Track(
		main:GetPropertyChangedSignal("AbsoluteSize"):
		Connect(State.UI.UpdateResponsiveLayout)
	)
	task.defer(State.UI.UpdateResponsiveLayout)
end

UI.PageScrollCues = {}

function UI.RefreshPageScrollCue(page)
	local cue = UI.PageScrollCues[page]
	if not cue or not cue.Parent or not page or not page.Parent then
		return
	end

	local maxY = math.max(
		page.AbsoluteCanvasSize.Y - page.AbsoluteWindowSize.Y,
		0
	)
	local scrollable = page.Visible and not page:GetAttribute("AAPHideScrollCue") and maxY > 8
	local atBottom = scrollable and page.CanvasPosition.Y >= maxY - 5
	cue.Visible = scrollable
	cue.Text = atBottom and "^" or "V"
	cue:SetAttribute("AAPScrollAtBottom", atBottom)
end

function UI.AttachPageScrollCue(page)
	if not page or UI.PageScrollCues[page] then
		return
	end

	local cue = Util.New("TextButton", {
		Name = page.Name .. "_ScrollCue",
		AnchorPoint = Vector2.new(1, 1),
		Position = UDim2.new(1, -6, 1, -6),
		Size = UDim2.fromOffset(28, 24),
		BackgroundColor3 = Theme.AccentDeep,
		BackgroundTransparency = 0.28,
		BorderSizePixel = 0,
		Text = "V",
		TextColor3 = Theme.Text,
		Font = Enum.Font.GothamBold,
		TextSize = 9,
		AutoButtonColor = false,
		Visible = false,
		ZIndex = 26,
	}, State.UI.PageHost)
	Util.Corner(cue, 999)
	Util.Gradient(cue, Theme.AccentDeep, Theme.AccentSoft, 90)
	Util.Stroke(cue, Theme.Accent, 0.38, 1)
	Util.Sheen(cue, 0.80)
	UI.TouchFeedback(cue)
	UI.PageScrollCues[page] = cue

	local function refresh()
		UI.RefreshPageScrollCue(page)
	end
	page:GetPropertyChangedSignal("CanvasPosition"):Connect(refresh)
	page:GetPropertyChangedSignal("AbsoluteCanvasSize"):Connect(refresh)
	page:GetPropertyChangedSignal("AbsoluteWindowSize"):Connect(refresh)

	cue.MouseButton1Click:Connect(function()
		local maxY = math.max(
			page.AbsoluteCanvasSize.Y - page.AbsoluteWindowSize.Y,
			0
		)
		local targetY = cue:GetAttribute("AAPScrollAtBottom")
			and 0
			or math.min(
				page.CanvasPosition.Y
					+ math.max(page.AbsoluteWindowSize.Y * 0.72, 120),
				maxY
			)
		Util.Tween(page, {CanvasPosition = Vector2.new(0, targetY)}, 0.16)
	end)

	task.defer(refresh)
end

function UI.CreatePage(name)
	local page = Util.New("ScrollingFrame", {
		Name = name,
		Position = UDim2.fromOffset(3, 3),
		Size = UDim2.new(1, -6, 1, -6),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ScrollBarThickness = 5,
		ScrollBarImageColor3 = Theme.Accent,
		ScrollBarImageTransparency = 0.14,
		ScrollingDirection = Enum.ScrollingDirection.Y,
		ElasticBehavior = Enum.ElasticBehavior.WhenScrollable,
		ScrollingEnabled = true,
		VerticalScrollBarInset = Enum.ScrollBarInset.ScrollBar,
		CanvasSize = UDim2.new(),
		Visible = false,
	}, State.UI.PageHost)

	local layout = Util.New("UIListLayout", {
		Padding = UDim.new(0, 8),
		SortOrder = Enum.SortOrder.LayoutOrder,
	}, page)
	UI.RegisterOrganizerContainer(page, name .. ":Page")

	Util.New("UIPadding", {
		PaddingLeft = UDim.new(0, 4),
		PaddingRight = UDim.new(0, 10),
		PaddingTop = UDim.new(0, 4),
		PaddingBottom = UDim.new(0, 12),
	}, page)

	layout:GetPropertyChangedSignal("AbsoluteContentSize"):
		Connect(function()

			page.CanvasSize =
				UDim2.fromOffset(
					0,
					layout.AbsoluteContentSize.Y + 16
				)
		end)

	UI.AttachPageScrollCue(page)

	return page
end

function UI.CreateNavButton(text)
	local button = Util.New("TextButton", {
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = Theme.Surface2,
		BackgroundTransparency = 0.12,
		BorderSizePixel = 0,
		Text = "",
		TextColor3 = Theme.Sub,
		Font = Enum.Font.GothamBold,
		TextSize = 8,
		TextXAlignment = Enum.TextXAlignment.Center,
		AutoButtonColor = false,
		ZIndex = 8,
	}, State.UI.NavHolder)

	Util.Corner(button, 999)
	Util.Sheen(button, 0.10)
	local stroke = Util.Stroke(button, Theme.BorderSoft, 0.68, 1)
	stroke.Name = "NavStroke"

	local navGlow = Util.New("Frame", {
		Name = "NavGlow",
		Position = UDim2.fromOffset(2, 2),
		Size = UDim2.new(1, -4, 1, -4),
		BackgroundColor3 = Theme.AccentSoft,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ZIndex = 8,
	}, button)
	Util.Corner(navGlow, 999)
	Util.Gradient(navGlow, Theme.AccentSoft, Theme.AccentDeep, 90)

	Util.FitText(Util.New("TextLabel", {
		Name = "NavTitle",
		Position = UDim2.fromOffset(4, 0),
		Size = UDim2.new(1, -8, 1, -5),
		BackgroundTransparency = 1,
		Text = text,
		TextColor3 = Theme.Sub,
		Font = Enum.Font.GothamBold,
		TextSize = 8,
		ZIndex = 10,
	}, button), 6, 10)

	local indicator = Util.New("Frame", {
		Name = "Indicator",
		AnchorPoint = Vector2.new(0.5, 1),
		Position = UDim2.new(0.5, 0, 1, -1),
		Size = UDim2.fromOffset(16, 2),
		BackgroundColor3 = Theme.Muted,
		BorderSizePixel = 0,
		ZIndex = 10,
	}, button)
	Util.Corner(indicator, 999)
	UI.TouchFeedback(button)

	return button
end

function UI.ShowPage(page)
	if UI.ActiveNumericSlider then UI.ActiveNumericSlider:FinishEditing(false) end
	if State.UI.ActiveChoiceMenu then
		UI.CloseChoiceMenu()
	end
	if State.UI.ActiveHelpDialog then
		UI.CloseHelpDialog()
	end

	for button, target in pairs(State.UI.PageMap) do
		local active = target == page
		local indicator = button:FindFirstChild("Indicator")
		local navStroke = button:FindFirstChild("NavStroke")
		local navTitle = button:FindFirstChild("NavTitle")
		local navGlow = button:FindFirstChild("NavGlow")

		target.Visible = active

		Util.Tween(
			button,
			{
				BackgroundColor3 =
					active and Theme.CardActive or Theme.Surface2,
				BackgroundTransparency = active and 0.02 or 0.12,
				TextColor3 =
					active and Theme.Text or Theme.Sub,
			},
			0.12
		)

		if navGlow then
			Util.Tween(
				navGlow,
				{BackgroundTransparency = active and 0.36 or 1},
				0.14
			)
		end

		if navStroke then
			Util.Tween(
				navStroke,
				{
					Color = active and Theme.Accent or Theme.BorderSoft,
					Transparency = active and 0.12 or 0.68,
				},
				0.12
			)
		end

		if navTitle then
			Util.Tween(
				navTitle,
				{TextColor3 = active and Theme.Text or Theme.Sub},
				0.12
			)
		end

		if indicator then
			Util.Tween(
				indicator,
				{
					BackgroundColor3 =
						active and Theme.Accent or Theme.Muted,
					Size =
						active
							and UDim2.fromOffset(27, 3)
							or UDim2.fromOffset(13, 2),
				},
				0.12
			)
		end
	end

	State.UI.ActivePage = page
	task.defer(function()
		for target in pairs(UI.PageScrollCues) do
			UI.RefreshPageScrollCue(target)
		end
	end)
end

function UI.ClampMovableToViewport()
	if not S.Camera then
		return
	end

	local viewport = S.Camera.ViewportSize

	for _, object in ipairs({
		State.UI.Main,
		State.UI.CompactBar,
		State.UI.MobileQuickControls,
	}) do
		if object and object.Parent then
			local size = object.AbsoluteSize
			local anchor = object.AnchorPoint
			local position = object.Position
			local baseX = viewport.X * position.X.Scale
			local baseY = viewport.Y * position.Y.Scale
			local currentX = baseX + position.X.Offset
			local currentY = baseY + position.Y.Offset

			local clampedX = Util.ClampAnchoredAxis(
				currentX,
				size.X,
				anchor.X,
				viewport.X,
				6
			)

			local clampedY = Util.ClampAnchoredAxis(
				currentY,
				size.Y,
				anchor.Y,
				viewport.Y,
				6
			)

			object.Position = UDim2.new(
				position.X.Scale,
				clampedX - baseX,
				position.Y.Scale,
				clampedY - baseY
			)
		end
	end
end

function UI.UpdateDebugLine(point)
	local line = State.UI.DebugLine

	if not line or not line.Parent
		or not Config.DebugEnabled
		or not Config.DebugShowTargetLine
		or not point
		or not S.Camera then

		if line then
			line.Visible = false
		end

		return
	end

	local projected =
		S.Camera:WorldToViewportPoint(point)

	if projected.Z <= 0 then
		line.Visible = false
		return
	end

	local viewport = S.Camera.ViewportSize
	local center = Vector2.new(
		viewport.X * 0.5,
		viewport.Y * 0.5
	)

	local target = Vector2.new(
		projected.X,
		projected.Y
	)

	local delta = target - center
	line.Position = UDim2.fromOffset(center.X, center.Y)
	line.Size = UDim2.fromOffset(delta.Magnitude, 1)
	line.Rotation = math.deg(math.atan2(delta.Y, delta.X))
	line.Visible = true
end

function UI.CreateRailToggle(parent, order, iconText, title, subtitle)
	local card = Util.New("TextButton", {
		Position = UDim2.fromOffset(6, 6 + (order - 1) * 44),
		Size = UDim2.new(1, -12, 0, 40),
		BackgroundColor3 = Theme.Card,
		BackgroundTransparency = 0.05,
		BorderSizePixel = 0,
		Text = "",
		AutoButtonColor = false,
	}, parent)
	Util.Corner(card, 16)
	Util.Sheen(card, 0.06)
	local stroke = Util.Stroke(card, Theme.BorderInner, 0.70, 1)


	local marker = Util.New("Frame", {
		Name = "Marker_" .. tostring(iconText),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0, 10, 0.5, 0),
		Size = UDim2.fromOffset(6, 6),
		BackgroundColor3 = Theme.Muted,
		BorderSizePixel = 0,
	}, card)
	Util.Corner(marker, 999)
	Util.Stroke(marker, Theme.BorderSoft, 0.28, 1)

	Util.FitText(Util.New("TextLabel", {
		Position = UDim2.fromOffset(18, 5),
		Size = UDim2.new(1, -64, 0, 14),
		BackgroundTransparency = 1,
		Text = title,
		TextColor3 = Theme.Text,
		Font = Enum.Font.GothamBold,
		TextSize = 7,
		TextWrapped = false,
		TextXAlignment = Enum.TextXAlignment.Left,
	}, card), 4, 8)

	local status = Util.New("TextLabel", {
		Position = UDim2.fromOffset(18, 21),
		Size = UDim2.new(1, -64, 0, 13),
		BackgroundTransparency = 1,
		Text = subtitle or "DESATIVADO",
		TextColor3 = Theme.Sub,
		Font = Enum.Font.Gotham,
		TextSize = 7,
		TextWrapped = false,
		TextXAlignment = Enum.TextXAlignment.Left,
	}, card)
	Util.FitText(status, 4, 8)

	local switch = Util.New("Frame", {
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -5, 0.5, 0),
		Size = UDim2.fromOffset(38, 22),
		BackgroundColor3 = Theme.Chip,
		BorderSizePixel = 0,
	}, card)
	Util.Corner(switch, 999)
	Util.Sheen(switch, 0.05)
	local switchStroke = Util.Stroke(switch, Theme.BorderSoft, 0.36, 1)

	local knob = Util.New("Frame", {
		Position = UDim2.fromOffset(3, 3),
		Size = UDim2.fromOffset(16, 16),
		BackgroundColor3 = Theme.Muted,
		BorderSizePixel = 0,
	}, switch)
	Util.Corner(knob, 999)
	Util.Sheen(knob, 0.01)
	UI.TouchFeedback(card)

	return {
		Card = card,
		Stroke = stroke,
		Marker = marker,
		Switch = switch,
		SwitchStroke = switchStroke,
		Knob = knob,
		Status = status,
	}
end

function UI.SetRailToggle(control, enabled)
	if not control then
		return
	end

	control.Card.BackgroundColor3 = enabled and Theme.CardActive or Theme.Card
	control.Stroke.Color = enabled and Theme.Accent or Theme.BorderSoft
	control.Stroke.Transparency = enabled and 0.20 or 0.52
	control.Status.Text = enabled and "ATIVADO" or "DESATIVADO"
	control.Status.TextColor3 = enabled and Theme.Accent2 or Theme.Sub
	if control.Marker then
		control.Marker.BackgroundColor3 = enabled and Theme.Accent or Theme.Muted
	end
	control.Switch.BackgroundColor3 = enabled and Theme.Accent or Theme.Chip
	control.SwitchStroke.Color = enabled and Theme.Accent2 or Theme.BorderSoft
	Util.Tween(
		control.Knob,
		{
			Position = enabled and UDim2.fromOffset(19, 3) or UDim2.fromOffset(3, 3),
			BackgroundColor3 = enabled and Theme.Text or Theme.Muted,
		},
		0.10
	)
end

function UI.CreateCompactSlider(parent, position, title, minimum, maximum, initial, suffix, callback)
	local holder = Util.New("Frame", {
		Position = position,
		Size = UDim2.new(1, 0, 0, 72),
		BackgroundTransparency = 1,
	}, parent)

	Util.New("TextLabel", {
		Position = UDim2.fromOffset(0, 0),
		Size = UDim2.new(1, 0, 0, 14),
		BackgroundTransparency = 1,
		Text = title,
		TextColor3 = Theme.Text,
		Font = Enum.Font.GothamBold,
		TextSize = 7,
		TextXAlignment = Enum.TextXAlignment.Left,
	}, holder)

	local valueLabel, valueStroke = UI.CreateSliderValueBox(holder,
		UDim2.fromOffset(26, 18), UDim2.new(1, -52, 0, 28))

	local hitArea = Util.New("TextButton", {
		Position = UDim2.fromOffset(0, 47),
		Size = UDim2.new(1, 0, 0, 25),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Text = "",
		AutoButtonColor = false,
	}, holder)

	local track = Util.New("Frame", {
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.new(0, 0, 0.5, 0),
		Size = UDim2.new(1, 0, 0, 6),
		BackgroundColor3 = Theme.Chip,
		BorderSizePixel = 0,
	}, hitArea)
	Util.Corner(track, 999)
	Util.Stroke(track, Theme.BorderSoft, 0.64, 1)

	local fill = Util.New("Frame", {
		Size = UDim2.fromScale(0, 1),
		BackgroundColor3 = Theme.Accent,
		BorderSizePixel = 0,
	}, track)
	Util.Corner(fill, 999)
	Util.Gradient(fill, Theme.Accent, Theme.Accent2, 0)

	local thumb = Util.New("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0, 0, 0.5, 0),
		Size = UDim2.fromOffset(16, 16),
		BackgroundColor3 = Theme.Text,
		BorderSizePixel = 0,
		Active = true,
	}, track)
	Util.Corner(thumb, 999)
	Util.Sheen(thumb, 0.01)
	Util.Stroke(thumb, Theme.Accent2, 0.02, 2)

	local decrease = UI.CreateSliderStepButton(holder, "−",
		UDim2.fromOffset(0, 18), UDim2.fromOffset(24, 28))
	local increase = UI.CreateSliderStepButton(holder, "+",
		UDim2.new(1, 0, 0, 18), UDim2.fromOffset(24, 28), Vector2.new(1, 0))

	local slider = {
		Decrease = decrease, Increase = increase, ValueStroke = valueStroke,
		Card = holder,
		Track = track,
		Fill = fill,
		Thumb = thumb,
		Label = valueLabel,
		Min = minimum,
		Max = maximum,
		Suffix = suffix or "",
		Callback = callback,
	}

	UI.BindSliderPrecision(slider)

	local function start(input)
		if not UI.SliderCanInteract(slider) then return end
		if input.UserInputType ~= Enum.UserInputType.Touch
			and input.UserInputType ~= Enum.UserInputType.MouseButton1 then
			return
		end

		if UI.ActiveSliderInput
			and UI.ActiveSliderInput ~= input then

			return
		end

		UI.ActiveSlider = slider
		UI.ActiveSliderInput = input
		local width = math.max(track.AbsoluteSize.X, 1)
		local alpha = math.clamp((input.Position.X - track.AbsolutePosition.X) / width, 0, 1)
		slider:SetValue(minimum + (maximum - minimum) * alpha, true)
	end

	hitArea.InputBegan:Connect(start)
	thumb.InputBegan:Connect(start)
	slider:SetValue(initial, false)
	return slider
end

function UI.CreateMiniCycle(parent, position, title)
	local button = Util.New("TextButton", {
		Position = position,
		Size = UDim2.new(1, 0, 0, 42),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Text = "",
		AutoButtonColor = false,
	}, parent)

	Util.New("TextLabel", {
		Position = UDim2.fromOffset(0, 0),
		Size = UDim2.new(1, 0, 0, 14),
		BackgroundTransparency = 1,
		Text = title,
		TextColor3 = Theme.Text,
		Font = Enum.Font.GothamBold,
		TextSize = 8,
		TextXAlignment = Enum.TextXAlignment.Left,
	}, button)

	local value = Util.New("TextLabel", {
		Position = UDim2.fromOffset(0, 15),
		Size = UDim2.new(1, -18, 0, 25),
		BackgroundColor3 = Theme.Card,
		BackgroundTransparency = 0.04,
		BorderSizePixel = 0,
		Text = "",
		TextColor3 = Theme.Sub,
		Font = Enum.Font.GothamBold,
		TextSize = 8,
		TextXAlignment = Enum.TextXAlignment.Left,
	}, button)
	Util.Corner(value, 999)
	Util.Sheen(value, 0.09)
	Util.Stroke(value, Theme.BorderInner, 0.70, 1)
	Util.New("UIPadding", {
		PaddingLeft = UDim.new(0, 5),
		PaddingRight = UDim.new(0, 5),
	}, value)
	Util.FitText(value, 6, 9)

	Util.New("TextLabel", {
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -4, 0, 15),
		Size = UDim2.fromOffset(16, 25),
		BackgroundTransparency = 1,
		Text = "V",
		TextColor3 = Theme.Dim,
		Font = Enum.Font.GothamBold,
		TextSize = 8,
	}, button)
	UI.TouchFeedback(button)

	return {Card = button, Value = value}
end

function UI.CreateMiniToggle(parent, position, title)
	local button = Util.New("TextButton", {
		Position = position,
		Size = UDim2.new(1, 0, 0, 42),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Text = "",
		AutoButtonColor = false,
	}, parent)

	Util.New("TextLabel", {
		Position = UDim2.fromOffset(0, 0),
		Size = UDim2.new(1, 0, 0, 14),
		BackgroundTransparency = 1,
		Text = title,
		TextColor3 = Theme.Text,
		Font = Enum.Font.GothamBold,
		TextSize = 8,
		TextXAlignment = Enum.TextXAlignment.Left,
	}, button)

	local value = Util.New("TextLabel", {
		Position = UDim2.fromOffset(0, 15),
		Size = UDim2.new(1, 0, 0, 25),
		BackgroundColor3 = Theme.Card,
		BackgroundTransparency = 0.04,
		BorderSizePixel = 0,
		Text = "",
		TextColor3 = Theme.Sub,
		Font = Enum.Font.GothamBold,
		TextSize = 8,
		TextXAlignment = Enum.TextXAlignment.Left,
	}, button)
	Util.Corner(value, 999)
	Util.Sheen(value, 0.09)
	local valueStroke = Util.Stroke(value, Theme.BorderInner, 0.70, 1)
	Util.New("UIPadding", {
		PaddingLeft = UDim.new(0, 6),
		PaddingRight = UDim.new(0, 47),
	}, value)
	Util.FitText(value, 6, 9)

	local switch = Util.New("Frame", {
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -3, 0, 27.5),
		Size = UDim2.fromOffset(38, 21),
		BackgroundColor3 = Theme.Chip,
		BorderSizePixel = 0,
	}, button)
	Util.Corner(switch, 999)
	local switchStroke = Util.Stroke(switch, Theme.BorderSoft, 0.42, 1)

	local knob = Util.New("Frame", {
		Position = UDim2.fromOffset(3, 3),
		Size = UDim2.fromOffset(15, 15),
		BackgroundColor3 = Theme.Muted,
		BorderSizePixel = 0,
	}, switch)
	Util.Corner(knob, 999)
	UI.TouchFeedback(button)

	return {
		Card = button,
		Value = value,
		ValueStroke = valueStroke,
		Switch = switch,
		SwitchStroke = switchStroke,
		Knob = knob,
	}
end

function UI.SetMiniToggle(control, enabled, enabledText, disabledText)
	if not control then
		return
	end

	control.Value.Text = enabled
		and (enabledText or "ATIVADO")
		or (disabledText or "DESATIVADO")
	control.Value.TextColor3 = enabled and Theme.Accent2 or Theme.Sub
	control.ValueStroke.Color = enabled and Theme.AccentSoft or Theme.BorderInner
	control.ValueStroke.Transparency = enabled and 0.34 or 0.70
	control.Switch.BackgroundColor3 = enabled and Theme.AccentSoft or Theme.Chip
	control.SwitchStroke.Color = enabled and Theme.Accent or Theme.BorderSoft
	control.SwitchStroke.Transparency = enabled and 0.18 or 0.42

	Util.Tween(
		control.Knob,
		{
			Position = enabled
				and UDim2.new(1, -18, 0, 3)
				or UDim2.fromOffset(3, 3),
			BackgroundColor3 = enabled and Theme.Text or Theme.Muted,
		},
		0.10
	)
end

function UI.LoadPlayerThumbnail(imageLabel, player)
	if not imageLabel or not player then
		return
	end

	local userId = player.UserId
	local cached = State.ThumbnailCache[userId]

	if cached then
		imageLabel.Image = cached
		return
	end

	local waiting = State.ThumbnailPending[userId]
	if waiting then
		waiting[#waiting + 1] = imageLabel
		return
	end

	waiting = {imageLabel}
	State.ThumbnailPending[userId] = waiting

	task.spawn(function()
		local imageId = nil

		for attempt = 1, 3 do
			local ok, result, ready = pcall(function()
				return S.Players:GetUserThumbnailAsync(
					userId,
					Enum.ThumbnailType.HeadShot,
					Enum.ThumbnailSize.Size100x100
				)
			end)

			if ok and result and result ~= "" then
				imageId = result
				if ready then
					break
				end
			end

			if attempt < 3 then
				task.wait(0.20 * attempt)
			end
		end

		if imageId
			and Runtime.Alive
			and player.Parent == S.Players then

			State.ThumbnailCache[userId] = imageId
		end

		if State.ThumbnailPending[userId] == waiting then
			State.ThumbnailPending[userId] = nil
		end

		if imageId then
			for _, waiter in ipairs(waiting) do
				if waiter and waiter.Parent then
					waiter.Image = imageId
				end
			end
		end
	end)
end

function UI.RefreshTargetSidebar()
	local container = State.UI.TargetList
	if not container or not container.Parent then
		return
	end

	for _, child in ipairs(container:GetChildren()) do
		if child:IsA("GuiObject") then
			child:Destroy()
		end
	end

	local query = ""
	if State.UI.TargetSearch then
		query = string.lower(State.UI.TargetSearch.Text or "")
	end

	local players = {}
	for _, player in ipairs(S.Players:GetPlayers()) do
		if player ~= S.LocalPlayer then
			local searchable = string.lower(player.DisplayName .. " " .. player.Name)
			if query == "" or string.find(searchable, query, 1, true) then
				players[#players + 1] = player
			end
		end
	end

	table.sort(players, function(a, b)
		local aName = string.lower(a.DisplayName)
		local bName = string.lower(b.DisplayName)

		if aName == bName then
			return a.UserId < b.UserId
		end

		return aName < bName
	end)

	for index, player in ipairs(players) do
		local selected = State.SelectedPlayers[player] == true
		local manualAlly = State.ManualAllies[player] == true
		local card = Util.New("TextButton", {
			Size = UDim2.new(1, -2, 0, 46),
			BackgroundColor3 = selected
				and Theme.CardActive
				or manualAlly
				and RelationColors.ALLY:Lerp(Theme.Card, 0.72)
				or Theme.Card,
			BackgroundTransparency = 0.04,
			BorderSizePixel = 0,
			Text = "",
			AutoButtonColor = false,
			LayoutOrder = index,
		}, container)
		Util.Corner(card, 13)
		Util.Sheen(card, 0.07)
		Util.Stroke(
			card,
			selected
				and Theme.Accent2
				or manualAlly
				and RelationColors.ALLY
				or Theme.BorderInner,
			(selected or manualAlly) and 0.12 or 0.68,
			1
		)


		local avatar = Util.New("ImageLabel", {
			Position = UDim2.fromOffset(6, 6),
			Size = UDim2.fromOffset(34, 34),
			BackgroundColor3 = Theme.Surface3,
			BorderSizePixel = 0,
			Image = "",
		}, card)
		Util.Corner(avatar, 11)
		Util.Stroke(avatar, Theme.BorderInner, 0.58, 1)

		Util.FitText(Util.New("TextLabel", {
			Position = UDim2.fromOffset(46, 6),
			Size = UDim2.new(1, -68, 0, 15),
			BackgroundTransparency = 1,
			Text = player.DisplayName,
			TextColor3 = Theme.Text,
			Font = Enum.Font.GothamBold,
			TextSize = 8,
			TextXAlignment = Enum.TextXAlignment.Left,
		}, card), 5, 9)

		Util.FitText(Util.New("TextLabel", {
			Position = UDim2.fromOffset(46, 25),
			Size = UDim2.new(1, -68, 0, 13),
			BackgroundTransparency = 1,
			Text = manualAlly and "PROTEGIDO" or Util.TeamName(player),
			TextColor3 = Util.TeamColor(player),
			Font = Enum.Font.Gotham,
			TextSize = 7,
			TextXAlignment = Enum.TextXAlignment.Left,
		}, card), 6, 9)

		local onlineDot = Util.New("Frame", {
			AnchorPoint = Vector2.new(1, 0.5),
			Position = UDim2.new(1, -9, 0, 10),
			Size = UDim2.fromOffset(7, 7),
			BackgroundColor3 = Theme.Success,
			BorderSizePixel = 0,
		}, card)
		Util.Corner(onlineDot, 999)
		Util.Stroke(onlineDot, Theme.Success, 0.48, 2)

		local check = Util.New("TextLabel", {
			AnchorPoint = Vector2.new(1, 0.5),
			Position = UDim2.new(1, -5, 0, 33),
			Size = UDim2.fromOffset(18, 18),
			BackgroundColor3 = selected
				and Theme.Accent
				or manualAlly
				and RelationColors.ALLY
				or Theme.Surface3,
			BorderSizePixel = 0,
			Text = selected and "✓" or manualAlly and "P" or "",
			TextColor3 = Theme.Text,
			Font = Enum.Font.GothamBold,
			TextSize = 7,
		}, card)
		Util.Corner(check, 999)
		Util.Stroke(
			check,
			selected
				and Theme.Accent2
				or manualAlly
				and RelationColors.ALLY
				or Theme.BorderSoft,
			0.45,
			1
		)

		UI.LoadPlayerThumbnail(avatar, player)

		card.MouseButton1Click:Connect(function()
			if selected then
				State.SelectedPlayers[player] = nil
				if Config.AimMode == "SELECTED" then
					Config.AimMode = "AUTO"
				end
				if State.CurrentTarget == player then
					Aim.ClearCurrentTarget("Jogador desmarcado")
				end
				ESP.SafeRefresh(player)
				if State.UI.RefreshPlayers then
					State.UI.RefreshPlayers()
				else
					UI.RefreshTargetSidebar()
				end
				if State.UI.RefreshAimControls then
					State.UI.RefreshAimControls()
				end
				if State.UI.RefreshFilters then
					State.UI.RefreshFilters()
				end
			else
				UI.SelectExclusivePlayer(
					player,
					"Jogador escolhido na lista lateral"
				)
			end
		end)
	end
end

function UI.RefreshTeamSidebar()
	local container = State.UI.TeamList
	if not container or not container.Parent then
		return
	end

	for _, child in ipairs(container:GetChildren()) do
		if child:IsA("GuiObject") then
			child:Destroy()
		end
	end

	local allies = {}
	for player in pairs(State.ManualAllies) do
		if player.Parent == S.Players then
			allies[#allies + 1] = player
		else
			State.ManualAllies[player] = nil
		end
	end

	table.sort(allies, function(a, b)
		local aName = string.lower(a.DisplayName)
		local bName = string.lower(b.DisplayName)
		if aName == bName then
			return a.UserId < b.UserId
		end
		return aName < bName
	end)

	if #allies == 0 then
		local empty = Util.New("TextLabel", {
			Size = UDim2.new(1, -4, 0, 43),
			BackgroundTransparency = 1,
			Text = "Ninguém protegido\nUse PROTEGER na aba JOGADORES",
			TextColor3 = Theme.Muted,
			Font = Enum.Font.Gotham,
			TextSize = 6,
			TextWrapped = true,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextYAlignment = Enum.TextYAlignment.Center,
		}, container)
		Util.FitText(empty, 5, 7)
		return
	end

	for index, player in ipairs(allies) do
		local row = Util.New("TextButton", {
			Size = UDim2.new(1, 0, 0, 28),
			BackgroundColor3 = RelationColors.ALLY:Lerp(Theme.Card, 0.76),
			BackgroundTransparency = 0.12,
			BorderSizePixel = 0,
			Text = "",
			AutoButtonColor = false,
			LayoutOrder = index,
		}, container)
		Util.Corner(row, 9)
		Util.Stroke(row, RelationColors.ALLY, 0.52, 1)

		local dot = Util.New("Frame", {
			AnchorPoint = Vector2.new(0, 0.5),
			Position = UDim2.new(0, 7, 0.5, 0),
			Size = UDim2.fromOffset(7, 7),
			BackgroundColor3 = RelationColors.ALLY,
			BorderSizePixel = 0,
		}, row)
		Util.Corner(dot, 999)

		Util.FitText(Util.New("TextLabel", {
			Position = UDim2.fromOffset(19, 0),
			Size = UDim2.new(1, -47, 1, 0),
			BackgroundTransparency = 1,
			Text = string.upper(player.DisplayName),
			TextColor3 = RelationColors.ALLY,
			Font = Enum.Font.GothamBold,
			TextSize = 7,
			TextXAlignment = Enum.TextXAlignment.Left,
		}, row), 5, 8)

		local check = Util.New("TextLabel", {
			AnchorPoint = Vector2.new(1, 0.5),
			Position = UDim2.new(1, -5, 0.5, 0),
			Size = UDim2.fromOffset(18, 18),
			BackgroundColor3 = Theme.Surface3,
			BorderSizePixel = 0,
			Text = "✓",
			TextColor3 = Theme.Text,
			Font = Enum.Font.GothamBold,
			TextSize = 7,
		}, row)
		Util.Corner(check, 999)
		Util.Stroke(check, RelationColors.ALLY, 0.48, 1)
		UI.TouchFeedback(row)

		row.MouseButton1Click:Connect(function()
			UI.SetManualAlly(player, false)
		end)
	end
end

--==============================================================
-- PAGE BUILDERS
--==============================================================

local RequestRelationStateRefresh
local Pages = {}

function Pages.BuildVisionAim()
	local page = UI.CreatePage("Aim")
	local controls = {
		PresetCards = {},
		SelectedPreset = nil,
	}

	UI.Section(
		page,
		"AJUSTES PRINCIPAIS",
		"Mira liga a ajuda. Manter alvo evita trocas. Ajuste o restante abaixo."
	)

	controls.RailAim = UI.CreateRailToggle(
		State.UI.LeftToggleHolder,
		1,
		"A",
		"MIRA",
		"DESATIVADO"
	)
	controls.RailLock = UI.CreateRailToggle(
		State.UI.LeftToggleHolder,
		2,
		"L",
		"MANTER ALVO",
		"DESATIVADO"
	)
	controls.RailESP = UI.CreateRailToggle(
		State.UI.LeftToggleHolder,
		3,
		"E",
		"ESP",
		"DESATIVADO"
	)

	local aimPanel = Util.New("Frame", {
		Size = UDim2.new(1, 0, 0, 304),
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		BorderSizePixel = 0,
		ClipsDescendants = true,
	}, page)
	Util.Corner(aimPanel, 15)
	Util.GlassGradient(
		aimPanel,
		Color3.fromRGB(24, 23, 31),
		Color3.fromRGB(11, 13, 19),
		0.04,
		0.01,
		90
	)
	Util.Stroke(aimPanel, Theme.BorderInner, 0.58, 1)
	Util.InnerHighlight(aimPanel, 14, 0.90)

	Util.New("TextLabel", {
		Position = UDim2.fromOffset(10, 7),
		Size = UDim2.new(0.35, -14, 0, 16),
		BackgroundTransparency = 1,
		Text = "CONTROLE",
		TextColor3 = Theme.Text,
		Font = Enum.Font.GothamBold,
		TextSize = 8,
		TextXAlignment = Enum.TextXAlignment.Left,
	}, aimPanel)

	Util.New("TextLabel", {
		Position = UDim2.new(0.35, 0, 0, 7),
		Size = UDim2.new(0.28, 0, 0, 16),
		BackgroundTransparency = 1,
		Text = "FOV NA TELA",
		TextColor3 = Theme.Text,
		Font = Enum.Font.GothamBold,
		TextSize = 8,
		TextXAlignment = Enum.TextXAlignment.Center,
	}, aimPanel)

	Util.New("TextLabel", {
		Position = UDim2.new(0.63, 8, 0, 7),
		Size = UDim2.new(0.37, -36, 0, 16),
		BackgroundTransparency = 1,
		Text = "REGRAS",
		TextColor3 = Theme.Text,
		Font = Enum.Font.GothamBold,
		TextSize = 8,
		TextXAlignment = Enum.TextXAlignment.Left,
	}, aimPanel)

	local sliderColumn = Util.New("Frame", {
		Position = UDim2.new(0, 12, 0, 28),
		Size = UDim2.new(0.35, -18, 1, -36),
		BackgroundTransparency = 1,
	}, aimPanel)

	controls.FOVSlider = UI.CreateCompactSlider(
		sliderColumn,
		UDim2.fromOffset(0, 0),
		"ÁREA (FOV)",
		10,
		2000,
		Config.FOV,
		" px",
		function(value)
			Config.FOV = math.floor(value + 0.5)
			Aim.MarkAssistantCustomized()
		end
	)

	controls.Accuracy = UI.CreateCompactSlider(
		sliderColumn,
		UDim2.fromOffset(0, 82),
		"PRECISÃO",
		0,
		100,
		Config.Accuracy,
		"%",
		function(value)
			Config.Accuracy = math.floor(value + 0.5)
			Aim.MarkAssistantCustomized()
		end
	)

	controls.Smoothing = UI.CreateCompactSlider(
		sliderColumn,
		UDim2.fromOffset(0, 164),
		"SUAVIDADE",
		0,
		100,
		Config.Smoothing,
		"%",
		function(value)
			Config.Smoothing = math.floor(value + 0.5)
			Aim.MarkAssistantCustomized()
		end
	)

	local fovColumn = Util.New("Frame", {
		Position = UDim2.new(0.35, 0, 0, 24),
		Size = UDim2.new(0.28, 0, 1, -32),
		BackgroundTransparency = 1,
	}, aimPanel)

	local fovCircle = Util.New("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.52),
		Size = UDim2.fromScale(0.80, 0.80),
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		BackgroundTransparency = 0,
		BorderSizePixel = 0,
	}, fovColumn)
	Util.Corner(fovCircle, 999)
	Util.GlassGradient(
		fovCircle,
		Color3.fromRGB(38, 15, 25),
		Color3.fromRGB(12, 12, 18),
		0.04,
		0.01,
		90
	)
	Util.Stroke(fovCircle, Theme.Accent2, 0.16, 1)
	Util.New("UIAspectRatioConstraint", {
		AspectRatio = 1,
		DominantAxis = Enum.DominantAxis.Width,
		AspectType = Enum.AspectType.FitWithinMaxSize,
	}, fovCircle)

	local fovInnerRing = Util.New("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromScale(0.72, 0.72),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
	}, fovCircle)
	Util.Corner(fovInnerRing, 999)
	Util.Stroke(fovInnerRing, Theme.Accent, 0.70, 1)
	Util.New("UISizeConstraint", {
		MinSize = Vector2.new(46, 46),
		MaxSize = Vector2.new(120, 120),
	}, fovCircle)

	local previewHorizontal = Util.New("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.new(1, -5, 0, 1),
		BackgroundColor3 = Theme.Accent,
		BackgroundTransparency = 0.78,
		BorderSizePixel = 0,
	}, fovCircle)
	local previewVertical = Util.New("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.new(0, 1, 1, -5),
		BackgroundColor3 = Theme.Accent,
		BackgroundTransparency = 0.78,
		BorderSizePixel = 0,
	}, fovCircle)
	local fovDot = Util.New("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromOffset(4, 4),
		BackgroundColor3 = Theme.Text,
		BorderSizePixel = 0,
	}, fovCircle)
	Util.Corner(fovDot, 999)

	local optionColumn = Util.New("Frame", {
		Position = UDim2.new(0.63, 8, 0, 28),
		Size = UDim2.new(0.37, -20, 1, -36),
		BackgroundTransparency = 1,
	}, aimPanel)

	controls.Mode = UI.CreateMiniCycle(
		optionColumn,
		UDim2.fromOffset(0, 0),
		"QUEM PODE SER ALVO"
	)
	controls.Wall = UI.CreateMiniCycle(
		optionColumn,
		UDim2.fromOffset(0, 48),
		"VERIFICAR PAREDES"
	)
	controls.Priority = UI.CreateMiniCycle(
		optionColumn,
		UDim2.fromOffset(0, 96),
		"PARTE DO CORPO"
	)
	controls.FOVStyle = UI.CreateMiniCycle(
		optionColumn,
		UDim2.fromOffset(0, 144),
		"VISUAL DO FOV"
	)
	controls.FOVVisibility = UI.CreateMiniToggle(
		optionColumn,
		UDim2.fromOffset(0, 192),
		"MOSTRAR FOV"
	)
	controls.FOVPreview = {
		Inner = fovInnerRing,
		Horizontal = previewHorizontal,
		Vertical = previewVertical,
		Dot = fovDot,
	}

	local aimHelp = Util.New("TextLabel", {
		Position = UDim2.fromOffset(10, 272),
		Size = UDim2.new(1, -20, 0, 24),
		BackgroundColor3 = Theme.Chip,
		BackgroundTransparency = 0.18,
		BorderSizePixel = 0,
		Text = "FOV maior procura mais longe. Precisão alta corrige mais. Suavidade alta deixa o movimento mais leve.",
		TextColor3 = Theme.Sub,
		Font = Enum.Font.GothamBold,
		TextSize = 7,
	}, aimPanel)
	Util.Corner(aimHelp, 999)
	Util.Stroke(aimHelp, Theme.BorderSoft, 0.72, 1)
	Util.FitText(aimHelp, 6, 8)

	local presetsPanel = Util.New("Frame", {
		Size = UDim2.new(1, 0, 0, 210),
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		BorderSizePixel = 0,
		ClipsDescendants = true,
	}, page)
	Util.Corner(presetsPanel, 15)
	Util.GlassGradient(
		presetsPanel,
		Color3.fromRGB(22, 23, 31),
		Color3.fromRGB(10, 12, 18),
		0.04,
		0.01,
		90
	)
	Util.Stroke(presetsPanel, Theme.BorderInner, 0.58, 1)
	Util.InnerHighlight(presetsPanel, 14, 0.90)

	Util.New("TextLabel", {
		Position = UDim2.fromOffset(10, 7),
		Size = UDim2.new(1, -20, 0, 16),
		BackgroundTransparency = 1,
		Text = "AJUSTES RÁPIDOS",
		TextColor3 = Theme.Text,
		Font = Enum.Font.GothamBold,
		TextSize = 8,
		TextXAlignment = Enum.TextXAlignment.Left,
	}, presetsPanel)

	local presetScroller = Util.New("ScrollingFrame", {
		Position = UDim2.fromOffset(8, 28),
		Size = UDim2.new(1, -16, 0, 132),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		CanvasSize = UDim2.new(),
		ScrollBarThickness = 2,
		ScrollBarImageColor3 = Theme.Accent,
		ScrollingDirection = Enum.ScrollingDirection.X,
		ElasticBehavior = Enum.ElasticBehavior.WhenScrollable,
		HorizontalScrollBarInset = Enum.ScrollBarInset.ScrollBar,
	}, presetsPanel)
	local presetLayout = Util.New("UIListLayout", {
		FillDirection = Enum.FillDirection.Horizontal,
		Padding = UDim.new(0, 7),
		SortOrder = Enum.SortOrder.LayoutOrder,
	}, presetScroller)
	Util.New("UIPadding", {
		PaddingLeft = UDim.new(0, 3),
		PaddingRight = UDim.new(0, 3),
		PaddingTop = UDim.new(0, 3),
		PaddingBottom = UDim.new(0, 3),
	}, presetScroller)
	presetLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		if presetScroller.Parent then
			presetScroller.CanvasSize =
				UDim2.fromOffset(presetLayout.AbsoluteContentSize.X + 10, 0)
		end
	end)

	local presetData = {
		{
			Key = "SOFT",
			Title = "SUAVE",
			Description = "Movimento suave e discreto.",
			Weapon = false,
			Mode = "SOFT",
			Color = Color3.fromRGB(77, 218, 143),
		},
		{
			Key = "STRONG",
			Title = "FORTE",
			Description = "Resposta rápida com ajuda alta.",
			Weapon = false,
			Mode = "STRONG",
			Color = Color3.fromRGB(247, 155, 67),
		},
		{
			Key = "MAXIMUM",
			Title = "MÁXIMO",
			Description = "Resposta imediata e força máxima.",
			Weapon = false,
			Mode = "MAXIMUM",
			ColorKey = "Accent",
		},
		{
			Key = "SNIPER",
			Title = "LONGA DISTÂNCIA",
			Description = "Pronto para longa distância.",
			Weapon = "SNIPER",
			Mode = "BALANCED",
			Color = Color3.fromRGB(72, 151, 232),
		},
		{
			Key = "SMG",
			Title = "CURTA DISTÂNCIA",
			Description = "Pronto para curta distância.",
			Weapon = "SMG",
			Mode = "STRONG",
			Color = Color3.fromRGB(167, 83, 233),
		},
	}

	local function presetColor(data)
		return data.ColorKey and Theme[data.ColorKey]
			or data.Color
			or Theme.Accent
	end

	local function setPresetVisual(control, active)
		local color = presetColor(control.Data)
		control.Card.BackgroundTransparency = active and 0 or 0.03
		control.Stroke.Color = active and color or Theme.BorderInner
		control.Stroke.Transparency = active and 0.04 or 0.60
		if control.Marker then
			control.Marker.BackgroundColor3 = color
		end
		if control.Gradient then
			control.Gradient.Color = ColorSequence.new(
				active
					and color:Lerp(Theme.CardActive, 0.54)
					or color:Lerp(Theme.Card, 0.76),
				active and Theme.CardActive or Theme.Card
			)
		end
		control.Check.Visible = active
	end

	State.UI.RefreshQuickPresetVisuals = function()
		controls.SelectedPreset = State.ActiveQuickPresetKey

		for key, control in pairs(controls.PresetCards) do
			setPresetVisual(control, key == controls.SelectedPreset)
		end
	end

	local function applyPreset(data)
		local weapon = data.Weapon or Config.AimAssistant.Weapon or "RIFLE"
		if Aim.ApplyAssistantPreset(weapon, data.Mode) then
			controls.SelectedPreset = data.Key
			State.ActiveQuickPresetKey = data.Key
			if State.UI.RefreshAssistantControls then
				State.UI.RefreshAssistantControls()
			end
			if State.UI.RefreshBodyControls then
				State.UI.RefreshBodyControls()
			end
			if State.UI.RefreshEngineControls then
				State.UI.RefreshEngineControls()
			end
			controls.Refresh()
			UI.Toast("Perfil aplicado: " .. data.Title)
		end
	end

	for index, data in ipairs(presetData) do
		local color = presetColor(data)
		local card = Util.New("TextButton", {
			Size = UDim2.fromOffset(124, 120),
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			BackgroundTransparency = 0.03,
			BorderSizePixel = 0,
			Text = "",
			AutoButtonColor = false,
			LayoutOrder = index,
		}, presetScroller)
		Util.Corner(card, 13)
		local cardGradient = Util.GlassGradient(
			card,
			color:Lerp(Theme.Card, 0.76),
			Theme.Card,
			0,
			0,
			90
		)
		local stroke = Util.Stroke(card, Theme.BorderInner, 0.60, 1)
		Util.InnerHighlight(card, 10, 0.86)

		local presetMarker = Util.New("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.new(0.5, 0, 0, 16),
			Size = UDim2.fromOffset(9, 9),
			BackgroundColor3 = color,
			BorderSizePixel = 0,
		}, card)
		Util.Corner(presetMarker, 999)
		Util.Stroke(presetMarker, color, 0.42, 3)
		Util.New("TextLabel", {
			Position = UDim2.fromOffset(6, 29),
			Size = UDim2.new(1, -12, 0, 14),
			BackgroundTransparency = 1,
			Text = data.Title,
			TextColor3 = Theme.Text,
			Font = Enum.Font.GothamBold,
			TextSize = 8,
		}, card)
		Util.New("TextLabel", {
			Position = UDim2.fromOffset(8, 48),
			Size = UDim2.new(1, -16, 0, 57),
			BackgroundTransparency = 1,
			Text = data.Description,
			TextColor3 = Theme.Sub,
			Font = Enum.Font.Gotham,
			TextSize = 7,
			TextWrapped = true,
			TextXAlignment = Enum.TextXAlignment.Center,
			TextYAlignment = Enum.TextYAlignment.Top,
		}, card)
		local check = Util.New("TextLabel", {
			AnchorPoint = Vector2.new(1, 1),
			Position = UDim2.new(1, -3, 1, -3),
			Size = UDim2.fromOffset(17, 17),
			BackgroundColor3 = Theme.Accent,
			BorderSizePixel = 0,
			Text = "✓",
			TextColor3 = Theme.Text,
			Font = Enum.Font.GothamBold,
			TextSize = 7,
			Visible = false,
		}, card)
		Util.Corner(check, 999)
		Util.Stroke(check, Theme.Accent2, 0.20, 1)
		UI.TouchFeedback(card)

		controls.PresetCards[data.Key] = {
			Card = card,
			Stroke = stroke,
			Check = check,
			Gradient = cardGradient,
			Marker = presetMarker,
			Data = data,
		}
		card.MouseButton1Click:Connect(function()
			applyPreset(data)
		end)
	end

	controls.Apply = Util.New("TextButton", {
		Position = UDim2.fromOffset(8, 174),
		Size = UDim2.new(1, -16, 0, 28),
		BackgroundColor3 = Theme.Card,
		BackgroundTransparency = 0.03,
		BorderSizePixel = 0,
		Text = "REAPLICAR PERFIL ESCOLHIDO",
		TextColor3 = Theme.Text,
		Font = Enum.Font.GothamBold,
		TextSize = 7,
		AutoButtonColor = false,
	}, presetsPanel)
	Util.Corner(controls.Apply, 999)
	Util.Sheen(controls.Apply, 0.07)
	Util.Stroke(controls.Apply, Theme.BorderInner, 0.58, 1)
	UI.TouchFeedback(controls.Apply)

	function controls.Refresh()
		UI.SetRailToggle(controls.RailAim, Config.AimEnabled)
		UI.SetRailToggle(controls.RailLock, Config.StickyTarget)
		UI.SetRailToggle(controls.RailESP, Config.ESPEnabled)

		controls.FOVSlider:SetValue(Config.FOV, false)
		controls.Accuracy:SetValue(Config.Accuracy, false)
		controls.Smoothing:SetValue(Config.Smoothing, false)
		controls.Mode.Value.Text =
			Config.AimMode == "AUTO" and "TODOS" or "SÓ O ESCOLHIDO"
		controls.Wall.Value.Text = Config.WallCheck and "ATIVADO" or "DESATIVADO"
		controls.FOVStyle.Value.Text =
			FOV_STYLE_LABELS[Config.FOVStyle] or "TÁTICO"
		UI.SetMiniToggle(
			controls.FOVVisibility,
			Config.ShowFOVCircle,
			"VISÍVEL",
			"OCULTO"
		)
		local fovStyle = Config.FOVStyle
		controls.FOVPreview.Inner.Visible =
			fovStyle == "TACTICAL" or fovStyle == "DUAL"
		controls.FOVPreview.Horizontal.Visible =
			fovStyle == "CROSS"
			or fovStyle == "DUAL"
			or fovStyle == "PRECISION"
		controls.FOVPreview.Vertical.Visible =
			controls.FOVPreview.Horizontal.Visible
		controls.FOVPreview.Dot.Visible =
			fovStyle == "DOT"
			or fovStyle == "CROSS"
			or fovStyle == "TACTICAL"
			or fovStyle == "PRECISION"
		local region = BodyRegions[Config.PrimaryBodyRegion]
		local part = BodyRigProfiles.Find(
			Config.BodyRigMode,
			Config.PrimaryBodyPartName
		)
		controls.Priority.Value.Text =
			part
			and part.Label
			or region and region.Label
			or "PADRÃO"

		local assistant = Config.AimAssistant
		local mode = assistant.Modes[assistant.Mode]
		local weapon = assistant.Weapons[assistant.Weapon]
		State.UI.RefreshQuickPresetVisuals()

		if State.UI.CurrentProfileLabel then
			State.UI.CurrentProfileLabel.Text =
				assistant.Applied
				and not assistant.Customized
				and mode
				and mode.Label
				or "PERSONALIZADO"
		end
		if State.UI.CurrentWeaponLabel then
			State.UI.CurrentWeaponLabel.Text =
				assistant.Applied
				and weapon
				and weapon.Label
				or WeaponProfileLabels[Config.WeaponProfile]
				or "PADRÃO"
		end
	end

	State.UI.RefreshAimControls = controls.Refresh

	controls.RailAim.Card.MouseButton1Click:Connect(function()
		UI.SetAimEnabled(
			not State.AimActivationIntent,
			"Assistência desativada pelo menu",
			true
		)
	end)

	controls.RailLock.Card.MouseButton1Click:Connect(function()
		Config.StickyTarget = not Config.StickyTarget
		Aim.MarkAssistantCustomized()
		Aim.ClearCurrentTarget("Manter alvo foi alterado")
		controls.Refresh()
	end)

	controls.RailESP.Card.MouseButton1Click:Connect(function()
		Config.ESPEnabled = not Config.ESPEnabled
		ESP.RefreshAll()
		controls.Refresh()
		if State.UI.RefreshESPControls then
			State.UI.RefreshESPControls()
		end
	end)

	UI.BindChoiceMenu(
		controls.Mode,
		"Quem pode ser alvo",
		{
			{Value = "AUTO", Label = "TODOS", Description = "Procura qualquer jogador que não esteja protegido."},
			{Value = "SELECTED", Label = "SÓ O ESCOLHIDO", Description = "Usa apenas a pessoa marcada com FOCAR."},
		},
		function()
			return Config.AimMode
		end,
		function(value)
			Config.AimMode = value
			Aim.ClearCurrentTarget("Modo de mira alterado")
			controls.Refresh()
			if State.UI.RefreshFilters then
				State.UI.RefreshFilters()
			end
		end
	)

	UI.BindChoiceMenu(
		controls.Wall,
		"Verificar paredes",
		{
			{Value = true, Label = "ATIVADO", Description = "Evita focar jogadores atrás de paredes."},
			{Value = false, Label = "DESATIVADO", Description = "Não verifica se existe algo na frente do jogador."},
		},
		function()
			return Config.WallCheck
		end,
		function(value)
			Config.WallCheck = value == true
			Aim.MarkAssistantCustomized()
			Aim.ClearCurrentTarget("Verificação de paredes alterada")
			controls.Refresh()
		end
	)

	local priorityChoices = {}
	for _, regionName in ipairs(BodyRegionOrder) do
		local region = BodyRegions[regionName]
		priorityChoices[#priorityChoices + 1] = {
			Value = regionName,
			Label = region and region.Label or regionName,
		}
	end
	UI.BindChoiceMenu(
		controls.Priority,
		"Parte do corpo",
		priorityChoices,
		function()
			return Config.PrimaryBodyRegion
		end,
		function(value)
			UI.SetPrimaryBodyRegion(value, {
				Reason = "Prioridade corporal alterada pela aba MIRA",
			})
			controls.Refresh()
		end
	)

	local fovStyleChoices = {}
	local fovStyleDescriptions = {
		RING = "Mostra apenas o limite da área de busca.",
		DOT = "Adiciona um ponto no centro do anel.",
		CROSS = "Mostra linhas cruzadas no centro.",
		TACTICAL = "Usa anel, ponto e marcas nas bordas.",
		DUAL = "Mostra dois anéis para facilitar a leitura.",
		PRECISION = "Usa linhas mais finas e discretas.",
	}
	for _, styleName in ipairs(FOV_STYLE_ORDER) do
		fovStyleChoices[#fovStyleChoices + 1] = {
			Value = styleName,
			Label = FOV_STYLE_LABELS[styleName] or styleName,
			Description = fovStyleDescriptions[styleName],
		}
	end
	UI.BindChoiceMenu(
		controls.FOVStyle,
		"Visual do FOV",
		fovStyleChoices,
		function()
			return Config.FOVStyle
		end,
		function(value)
			UI.ApplyFOVStyle(value)
			controls.Refresh()
			UI.Toast(
				"Visual do FOV: "
				.. (FOV_STYLE_LABELS[Config.FOVStyle] or Config.FOVStyle)
			)
		end
	)

	controls.FOVVisibility.Card.MouseButton1Click:Connect(function()
		Config.ShowFOVCircle = not Config.ShowFOVCircle
		State.UI.FOV.Visible =
			Config.FOVEnabled and Config.ShowFOVCircle
		controls.Refresh()
		UI.Toast(
			Config.ShowFOVCircle
				and "FOV visível na tela"
				or "FOV oculto. A área de busca continua funcionando."
		)
	end)

	controls.Apply.MouseButton1Click:Connect(function()
		local assistant = Config.AimAssistant
		local quickPresetKey = State.ActiveQuickPresetKey
		if Aim.ApplyAssistantPreset(
			assistant.Weapon or "RIFLE",
			assistant.Mode or "BALANCED"
		) then
			State.ActiveQuickPresetKey = quickPresetKey
			if State.UI.RefreshAssistantControls then
				State.UI.RefreshAssistantControls()
			end
			if State.UI.RefreshBodyControls then
				State.UI.RefreshBodyControls()
			end
			if State.UI.RefreshEngineControls then
				State.UI.RefreshEngineControls()
			end
			controls.Refresh()
			UI.Toast("Perfil atual aplicado")
		end
	end)

	local advancedContent = UI.CreateExpandableGroup(
		page,
		"AJUSTES AVANÇADOS",
		"Abra para ajustar a correção e o movimento da mira.",
		false
	)
	State.UI.AimAdvancedContainer = advancedContent

	controls.Refresh()
	return page
end

function Pages.BuildAssistant()
	local page = UI.CreatePage("Assistant")
	local assistantDefinition = Persistence.DefaultConfig.AimAssistant
	local controls = {
		WeaponCards = {},
		ModeCards = {},
	}

	UI.Section(
		page,
		"PERFIL RÁPIDO",
		"Escolha sua arma e a força da ajuda. O restante fica pronto sozinho."
	)

	local statusCard = Util.New("Frame", {
		Size = UDim2.new(1, 0, 0, 92),
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		BorderSizePixel = 0,
	}, page)
	Util.Corner(statusCard, 15)
	Util.GlassGradient(
		statusCard,
		Color3.fromRGB(56, 22, 34),
		Color3.fromRGB(17, 15, 22),
		0.02,
		0.01,
		90
	)
	Util.InnerHighlight(statusCard, 13, 0.87)
	controls.StatusStroke =
		Util.Stroke(
			statusCard,
			Theme.Accent,
			0.22,
			1
		)

	Util.New("TextLabel", {
		Position = UDim2.fromOffset(13, 9),
		Size = UDim2.new(1, -104, 0, 14),
		BackgroundTransparency = 1,
		Text = "PERFIL ESCOLHIDO",
		TextColor3 = Theme.Dim,
		Font = Enum.Font.GothamBold,
		TextSize = 6,
		TextXAlignment = Enum.TextXAlignment.Left,
	}, statusCard)

	controls.StatusChip = Util.New("TextLabel", {
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -11, 0, 9),
		Size = UDim2.fromOffset(78, 22),
		BackgroundColor3 = Theme.Chip,
		BorderSizePixel = 0,
		Text = "PRONTO",
		TextColor3 = Theme.Sub,
		Font = Enum.Font.GothamBold,
		TextSize = 6,
	}, statusCard)
	Util.Corner(controls.StatusChip, 10)
	Util.Sheen(controls.StatusChip, 0.08)
	Util.Stroke(controls.StatusChip, Theme.BorderSoft, 0.60, 1)

	controls.StatusTitle = Util.New("TextLabel", {
		Position = UDim2.fromOffset(13, 29),
		Size = UDim2.new(1, -26, 0, 22),
		BackgroundTransparency = 1,
		Text = "",
		TextColor3 = Theme.Text,
		Font = Enum.Font.GothamBold,
		TextSize = 10,
		TextXAlignment = Enum.TextXAlignment.Left,
	}, statusCard)

	controls.StatusText = Util.New("TextLabel", {
		Position = UDim2.fromOffset(13, 55),
		Size = UDim2.new(1, -26, 0, 30),
		BackgroundTransparency = 1,
		Text = "",
		TextColor3 = Theme.Sub,
		Font = Enum.Font.Gotham,
		TextSize = 7,
		TextWrapped = true,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Top,
	}, statusCard)

	local function createChoiceCard(parent, title, description)
		local card = Util.New("TextButton", {
			BackgroundColor3 = Theme.Card,
			BackgroundTransparency = 0.04,
			BorderSizePixel = 0,
			Text = "",
			AutoButtonColor = false,
		}, parent)
		Util.Corner(card, 13)
		Util.Sheen(card, 0.07)

		local stroke = Util.Stroke(
			card,
			Theme.BorderInner,
			0.68,
			1
		)

		local titleLabel = Util.New("TextLabel", {
			Position = UDim2.fromOffset(13, 8),
			Size = UDim2.new(1, -26, 0, 16),
			BackgroundTransparency = 1,
			Text = title,
			TextColor3 = Theme.Text,
			Font = Enum.Font.GothamBold,
			TextSize = 8,
			TextXAlignment = Enum.TextXAlignment.Left,
		}, card)

		local descriptionLabel = Util.New("TextLabel", {
			Position = UDim2.fromOffset(13, 27),
			Size = UDim2.new(1, -23, 0, 27),
			BackgroundTransparency = 1,
			Text = description,
			TextColor3 = Theme.Sub,
			Font = Enum.Font.Gotham,
			TextSize = 7,
			TextWrapped = true,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextYAlignment = Enum.TextYAlignment.Top,
		}, card)

		UI.TouchFeedback(card)

		return {
			Card = card,
			Stroke = stroke,
			Title = titleLabel,
			Description = descriptionLabel,
		}
	end

	local function setChoiceSelected(control, selected)
		control.Card.BackgroundColor3 =
			selected
			and Theme.CardActive
			or Theme.Card

		control.Stroke.Color =
			selected
			and Theme.Accent2
			or Theme.BorderInner

		control.Stroke.Transparency =
			selected
			and 0.10
			or 0.68

		control.Title.TextColor3 = selected and Theme.Accent2 or Theme.Text
	end

	local function refreshLinkedControls()
		for _, callback in ipairs({
			State.UI.RefreshAimControls,
			State.UI.RefreshBodyControls,
			State.UI.RefreshEngineControls,
		}) do
			if callback then
				callback()
			end
		end

		UI.RefreshQuick()
	end

	UI.Section(
		page,
		"1. TIPO DE ARMA",
		"Escolha a opção mais parecida com a arma que você está usando."
	)

	local weaponGrid = Util.New("Frame", {
		Size = UDim2.new(1, 0, 0, 280),
		BackgroundTransparency = 1,
	}, page)

	Util.New("UIGridLayout", {
		CellSize = UDim2.new(0.5, -4, 0, 64),
		CellPadding = UDim2.fromOffset(8, 8),
		FillDirectionMaxCells = 2,
		SortOrder = Enum.SortOrder.LayoutOrder,
	}, weaponGrid)

	for index, key in ipairs(assistantDefinition.WeaponOrder) do
		local data = assistantDefinition.Weapons[key]
		local control = createChoiceCard(
			weaponGrid,
			data.Label,
			data.Description
		)

		control.Card.LayoutOrder = index
		controls.WeaponCards[key] = control

		control.Card.MouseButton1Click:
			Connect(function()
				local assistant = Config.AimAssistant
				if Aim.ApplyAssistantPreset(
					key,
					assistant.Mode
				) then

					refreshLinkedControls()
					controls.Refresh()

					UI.Toast(
						"Perfil aplicado: "
						.. data.Label
						.. " • "
						.. assistant.Modes[assistant.Mode].Label
					)
				end
			end)
	end

	UI.Section(
		page,
		"2. FORÇA DA AJUDA",
		"Suave corrige menos. Forte e Máximo respondem mais rápido."
	)

	local modeGrid = Util.New("Frame", {
		Size = UDim2.new(1, 0, 0, 148),
		BackgroundTransparency = 1,
	}, page)

	Util.New("UIGridLayout", {
		CellSize = UDim2.new(0.5, -4, 0, 70),
		CellPadding = UDim2.fromOffset(8, 8),
		FillDirectionMaxCells = 2,
		SortOrder = Enum.SortOrder.LayoutOrder,
	}, modeGrid)

	for index, key in ipairs(assistantDefinition.ModeOrder) do
		local data = assistantDefinition.Modes[key]
		local control = createChoiceCard(
			modeGrid,
			data.Label,
			data.Description
		)

		control.Card.LayoutOrder = index
		controls.ModeCards[key] = control

		control.Card.MouseButton1Click:
			Connect(function()
				local assistant = Config.AimAssistant
				if Aim.ApplyAssistantPreset(
					assistant.Weapon,
					key
				) then

					refreshLinkedControls()
					controls.Refresh()

					UI.Toast(
						"Perfil aplicado: "
						.. assistant.Weapons[assistant.Weapon].Label
						.. " • "
						.. data.Label
					)
				end
			end)
	end

	local notice = Util.New("Frame", {
		Size = UDim2.new(1, 0, 0, 68),
		BackgroundColor3 = Theme.Surface2,
		BackgroundTransparency = 0.04,
		BorderSizePixel = 0,
	}, page)
	Util.Corner(notice, 14)
	Util.Sheen(notice, 0.08)
	Util.Stroke(notice, Theme.BorderInner, 0.68, 1)

	Util.New("TextLabel", {
		Position = UDim2.fromOffset(12, 8),
		Size = UDim2.new(1, -24, 0, 16),
		BackgroundTransparency = 1,
		Text = "ISSO NÃO MUDA SEUS JOGADORES",
		TextColor3 = Theme.Text,
		Font = Enum.Font.GothamBold,
		TextSize = 7,
		TextXAlignment = Enum.TextXAlignment.Left,
	}, notice)

	Util.New("TextLabel", {
		Position = UDim2.fromOffset(12, 27),
		Size = UDim2.new(1, -24, 0, 34),
		BackgroundTransparency = 1,
		Text = "Só os ajustes da mira são alterados. Jogadores protegidos, alvo escolhido e ESP continuam como estão.",
		TextColor3 = Theme.Sub,
		Font = Enum.Font.Gotham,
		TextSize = 7,
		TextWrapped = true,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Top,
	}, notice)

	function controls.Refresh()
		local assistant = Config.AimAssistant
		local weapon =
			assistant.Weapons[assistant.Weapon]
			or assistant.Weapons.RIFLE

		local mode =
			assistant.Modes[assistant.Mode]
			or assistant.Modes.BALANCED

		local region = BodyRegions[Config.PrimaryBodyRegion]
		local focusLabel = region and region.Label or "ALVO"
		local predictionLabel = "DESATIVADA"

		if Config.Prediction then
			predictionLabel =
				Config.PredictionMode == "MANUAL"
				and "MANUAL"
				or "AUTOMÁTICA"
		end

		for key, control in pairs(controls.WeaponCards) do
			setChoiceSelected(
				control,
				key == assistant.Weapon
			)
		end

		for key, control in pairs(controls.ModeCards) do
			setChoiceSelected(
				control,
				key == assistant.Mode
			)
		end

		controls.StatusTitle.Text =
			weapon.Label
				.. " • "
			.. mode.Label

		if assistant.Applied then
			controls.StatusChip.Text =
				assistant.Customized
				and "AJUSTADO"
				or "APLICADO"
			controls.StatusChip.BackgroundColor3 = Theme.AccentSoft
			controls.StatusChip.TextColor3 =
				Theme.Text

			controls.StatusText.Text =
				"Perfil aplicado.\nParte: "
				.. focusLabel
				.. " • Previsão: "
				.. predictionLabel
		else
			controls.StatusChip.Text = "PRONTO"
			controls.StatusChip.BackgroundColor3 = Theme.Chip
			controls.StatusChip.TextColor3 = Theme.Sub
			controls.StatusText.Text =
				"Escolha uma arma e a força da ajuda para aplicar o perfil."
		end
	end

	State.UI.RefreshAssistantControls = controls.Refresh
	controls.Refresh()

	return page
end

function Pages.BuildBody()
	local page = UI.CreatePage("Body")
	local controls = {
		SelectedRegion = Config.PrimaryBodyRegion,
		LastPrimaryRegion = Config.PrimaryBodyRegion,
		SelectedPartName = Config.PrimaryBodyPartName,
		LastPrimaryPartName = Config.PrimaryBodyPartName,
		RigMode = Config.BodyRigMode,
		LastRigMode = Config.BodyRigMode,
		RigButtons = {},
	}

	UI.Section(
		page,
		"ONDE MIRAR",
		"Escolha R6 ou R15 e toque na parte do boneco que a mira deve priorizar."
	)

	local panel = Util.New("Frame", {
		Size = UDim2.new(1, 0, 0, 360),
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		BorderSizePixel = 0,
	}, page)
	Util.Corner(panel, 18)
	Util.GlassGradient(
		panel,
		Color3.fromRGB(23, 24, 33),
		Color3.fromRGB(9, 11, 17),
		0.04,
		0.01,
		90
	)
	Util.Stroke(panel, Theme.BorderInner, 0.58, 1)
	Util.InnerHighlight(panel, 15, 0.90)

	local viewport = Util.New("ViewportFrame", {
		Position = UDim2.fromOffset(12, 12),
		Size = UDim2.new(0.48, -18, 1, -24),
		BackgroundColor3 = Color3.fromRGB(14, 15, 19),
		BorderSizePixel = 0,
		Ambient = Color3.fromRGB(215, 215, 220),
		LightColor = Color3.fromRGB(255, 255, 255),
		LightDirection = Vector3.new(-0.5, -1, -0.6),
		ClipsDescendants = true,
	}, panel)
	Util.Corner(viewport, 16)
	Util.Stroke(viewport, Theme.BorderInner, 0.58, 1)
	Util.InnerHighlight(viewport, 12, 0.91, 7)

	local world = Util.New("WorldModel", {}, viewport)

	local camera = Instance.new("Camera")
	camera.CFrame = CFrame.new(0, 2.4, 7.2) * CFrame.Angles(0, math.rad(180), 0)
	camera.Parent = viewport
	viewport.CurrentCamera = camera

	Util.New("TextLabel", {
		Position = UDim2.fromOffset(14, 11),
		Size = UDim2.new(1, -28, 0, 19),
		BackgroundTransparency = 1,
		Text = "BONECO DE TESTE",
		TextColor3 = Theme.Sub,
		Font = Enum.Font.GothamBold,
		TextSize = 7,
		TextXAlignment = Enum.TextXAlignment.Left,
		ZIndex = 8,
	}, viewport)

	local rigSelector = Util.New("Frame", {
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.new(0.5, 0, 0, 32),
		Size = UDim2.new(1, -20, 0, 32),
		BackgroundColor3 = Theme.Chip,
		BackgroundTransparency = 0.04,
		BorderSizePixel = 0,
		ZIndex = 12,
	}, viewport)
	Util.New("UISizeConstraint", {
		MinSize = Vector2.new(100, 32),
		MaxSize = Vector2.new(184, 32),
	}, rigSelector)
	Util.Corner(rigSelector, 999)
	Util.Stroke(rigSelector, Theme.BorderInner, 0.56, 1)
	Util.Sheen(rigSelector, 0.08)
	Util.New("UIPadding", {
		PaddingLeft = UDim.new(0, 3),
		PaddingRight = UDim.new(0, 3),
		PaddingTop = UDim.new(0, 3),
		PaddingBottom = UDim.new(0, 3),
	}, rigSelector)
	Util.New("UIGridLayout", {
		CellSize = UDim2.new(0.5, -2, 1, 0),
		CellPadding = UDim2.fromOffset(4, 0),
		FillDirectionMaxCells = 2,
		SortOrder = Enum.SortOrder.LayoutOrder,
	}, rigSelector)

	for index, rigName in ipairs({"R6", "R15"}) do
		local button = Util.New("TextButton", {
			BackgroundColor3 = Theme.Card,
			BackgroundTransparency = 0.08,
			BorderSizePixel = 0,
			Text = rigName,
			TextColor3 = Theme.Sub,
			Font = Enum.Font.GothamBold,
			TextSize = 8,
			AutoButtonColor = false,
			LayoutOrder = index,
			ZIndex = 13,
		}, rigSelector)
		Util.Corner(button, 999)
		local stroke = Util.Stroke(button, Theme.BorderSoft, 0.64, 1)
		UI.TouchFeedback(button)
		controls.RigButtons[rigName] = {
			Button = button,
			Stroke = stroke,
		}
	end

	local previewHint = Util.New("TextLabel", {
		AnchorPoint = Vector2.new(0.5, 1),
		Position = UDim2.new(0.5, 0, 1, -10),
		Size = UDim2.new(1, -24, 0, 27),
		BackgroundColor3 = Theme.Chip,
		BackgroundTransparency = 0.08,
		BorderSizePixel = 0,
		Text = "Toque em uma parte  •  Arraste para girar",
		TextColor3 = Theme.Sub,
		Font = Enum.Font.GothamBold,
		TextSize = 7,
		ZIndex = 12,
	}, viewport)

	Util.Corner(previewHint, 11)
	Util.Sheen(previewHint, 0.08)
	Util.Stroke(
		previewHint,
		Theme.BorderSoft,
		0.35,
		1
	)
	Util.FitText(previewHint, 6, 8)

	local Preview = {
		Model = nil,
		Root = nil,
		SelectionOverlays = {},
		LoadGeneration = 0,
		Rotation = 180,
		DragInput = nil,
		DragStart = nil,
		DragRotation = 180,
		DragMoved = false,
		FramePending = false,
	}

	local RegionParts = {
		Head = {
			"Head",
		},
		Torso = {
			"UpperTorso",
			"LowerTorso",
			"Torso",
		},
		LeftArm = {
			"LeftUpperArm",
			"LeftLowerArm",
			"LeftHand",
			"Left Arm",
		},
		RightArm = {
			"RightUpperArm",
			"RightLowerArm",
			"RightHand",
			"Right Arm",
		},
		LeftLeg = {
			"LeftUpperLeg",
			"LeftLowerLeg",
			"LeftFoot",
			"Left Leg",
		},
		RightLeg = {
			"RightUpperLeg",
			"RightLowerLeg",
			"RightFoot",
			"Right Leg",
		},
	}

	local regionNames = {
		Head = "CABEÇA",
		Torso = "TRONCO",
		LeftArm = "BRAÇO ESQUERDO",
		RightArm = "BRAÇO DIREITO",
		LeftLeg = "PERNA ESQUERDA",
		RightLeg = "PERNA DIREITA",
	}

	local PartToRegion = {}
	local PartLabels = {}

	for regionName, names in pairs(RegionParts) do
		for _, partName in ipairs(names) do
			PartToRegion[partName] = regionName
		end
	end

	for _, profile in pairs(BodyRigProfiles) do
		if type(profile) == "table" and profile.Parts then
			for _, entry in ipairs(profile.Parts) do
				PartLabels[entry.Name] = entry.Label
				PartToRegion[entry.Name] = entry.Region
			end
		end
	end

	local function clearWorld()
		Preview.Model = nil
		Preview.Root = nil
		Preview.SelectionOverlays = {}

		for _, child in ipairs(world:GetChildren()) do
			child:Destroy()
		end
	end

	local function getDescription()
		local character =
			S.LocalPlayer.Character

		local humanoid =
			character
			and character:FindFirstChildOfClass("Humanoid")

		if humanoid then
			local ok, applied =
				pcall(function()
					return humanoid:GetAppliedDescription()
				end)

			if ok and applied then
				return applied
			end
		end

		local ok, description =
			pcall(function()
				return S.Players:
					GetHumanoidDescriptionFromUserIdAsync(
						S.LocalPlayer.UserId
					)
			end)

		if ok and description then
			return description
		end

		return nil
	end

	local function createPreviewModel()
		local description =
			getDescription()
		local rigProfile =
			BodyRigProfiles[controls.RigMode]
			or BodyRigProfiles.R15

		if description then
			local ok, model =
				pcall(function()
					return S.Players:
						CreateHumanoidModelFromDescriptionAsync(
							description,
							rigProfile.RigType
						)
				end)

			if ok and model then
				return model
			end
		end

		-- Fallback for experiences that restrict description APIs on the
		-- client: clone the already replicated local character instead.
		local character = S.LocalPlayer.Character

		if character and character.Parent then
			local characterHumanoid =
				character:FindFirstChildOfClass("Humanoid")

			if characterHumanoid
				and characterHumanoid.RigType ~= rigProfile.RigType then

				return nil
			end

			local previousArchivable = character.Archivable
			character.Archivable = true

			local ok, clone = pcall(function()
				return character:Clone()
			end)

			character.Archivable = previousArchivable

			if ok and clone then
				return clone
			end
		end

		return nil
	end

	local function sanitizeModel(model)
		for _, item in ipairs(model:GetDescendants()) do
			if item:IsA("Tool")
				or item:IsA("ForceField")
				or item:IsA("Script")
				or item:IsA("LocalScript")
				or item:IsA("ModuleScript") then

				item:Destroy()

			elseif item:IsA("Animator") then
				item:Destroy()

			elseif item:IsA("BasePart") then
				-- IMPORTANT:
				-- Do not anchor every body part. Anchoring every limb
				-- freezes pieces independently and can visually break
				-- the Motor6D rig inside a ViewportFrame.
				item.Anchored = false
				item.CanCollide = false
				item.CanTouch = false
				item.CanQuery = true
				item.CastShadow = false
				item.LocalTransparencyModifier = 0
				item.AssemblyLinearVelocity = Vector3.zero
				item.AssemblyAngularVelocity = Vector3.zero

			elseif item:IsA("ParticleEmitter")
				or item:IsA("Trail")
				or item:IsA("Beam")
				or item:IsA("Smoke")
				or item:IsA("Fire")
				or item:IsA("Sparkles") then

				item.Enabled = false
			end
		end

		local humanoid =
			model:FindFirstChildOfClass("Humanoid")

		if humanoid then
			humanoid.DisplayDistanceType =
				Enum.HumanoidDisplayDistanceType.None

			humanoid.AutoRotate = false
			humanoid.PlatformStand = true

		end

		local root =
			model:FindFirstChild("HumanoidRootPart")
			or model:FindFirstChild("UpperTorso")
			or model:FindFirstChild("Torso")

		if root then
			Preview.Root = root
			model.PrimaryPart = root

			-- Root only. All other body parts remain attached by joints.
			root.Anchored = true
			root.CanQuery = false
			root.Transparency = 1
		end
	end

	local function placeModelFront(model)
		-- Roblox's default forward direction is -Z.
		-- Rotate the avatar 180 degrees so it faces +Z,
		-- then place the camera on +Z looking back at it.
		model:PivotTo(
			CFrame.new(0, 0, 0)
			*
			CFrame.Angles(
				0,
				math.rad(Preview.Rotation),
				0
			)
		)
	end

	local function getBodyBounds(model)
		local minV = Vector3.new(
			math.huge,
			math.huge,
			math.huge
		)

		local maxV = Vector3.new(
			-math.huge,
			-math.huge,
			-math.huge
		)

		local found = false

		for _, item in ipairs(model:GetDescendants()) do
			if item:IsA("BasePart")
				and item.Name ~= "HumanoidRootPart"
				and not item:FindFirstAncestorOfClass("Accessory") then

				local half =
					item.Size * 0.5

				local p =
					item.Position

				minV = Vector3.new(
					math.min(minV.X, p.X - half.X),
					math.min(minV.Y, p.Y - half.Y),
					math.min(minV.Z, p.Z - half.Z)
				)

				maxV = Vector3.new(
					math.max(maxV.X, p.X + half.X),
					math.max(maxV.Y, p.Y + half.Y),
					math.max(maxV.Z, p.Z + half.Z)
				)

				found = true
			end
		end

		if not found then
			local cf, size =
				model:GetBoundingBox()

			return cf.Position, size
		end

		local center =
			(minV + maxV) * 0.5

		local size =
			maxV - minV

		return center, size
	end

	local function frameModel(model)
		local center, size =
			getBodyBounds(model)

		local height =
			math.max(size.Y, 4)

		local width =
			math.max(size.X, 2)

		camera.FieldOfView = 36

		local tanHalf =
			math.tan(
				math.rad(
					camera.FieldOfView * 0.5
				)
			)

		local verticalDistance =
			(height * 0.5)
			/ tanHalf

		local viewportSize = viewport.AbsoluteSize
		local aspect = math.max(
			viewportSize.X / math.max(viewportSize.Y, 1),
			0.35
		)
		local horizontalDistance =
			(width * 0.5) / (tanHalf * aspect)

		-- Keep the complete body comfortably inside the preview. The larger
		-- margin makes every limb visible without making touch selection vague.
		local distance =
			math.max(
				verticalDistance * 1.88,
				horizontalDistance * 1.88,
				9.5
			)

		camera.CFrame =
			CFrame.lookAt(
				center
					+
					Vector3.new(
						0,
						height * 0.015,
						distance
					),
				center
			)
	end

	local function schedulePreviewFrame()
		if Preview.FramePending then
			return
		end

		Preview.FramePending = true
		task.defer(function()
			Preview.FramePending = false

			if Runtime.Alive
				and viewport.Parent
				and Preview.Model
				and Preview.Model.Parent == world then

				frameModel(Preview.Model)
			end
		end)
	end

	viewport:GetPropertyChangedSignal("AbsoluteSize"):
		Connect(schedulePreviewFrame)

	local function getPreviewPart(partName)
		if not Preview.Model or not partName then
			return nil
		end

		local part = Preview.Model:FindFirstChild(partName, true)
		return part and part:IsA("BasePart") and part or nil
	end

	local function clearSelectionOverlays()
		for _, overlay in ipairs(
			Preview.SelectionOverlays
		) do
			if overlay then
				overlay:Destroy()
			end
		end

		Preview.SelectionOverlays = {}
	end

	local function createSelectionOverlay(part)
		local previousArchivable = part.Archivable
		part.Archivable = true

		local ok, overlay = pcall(function()
			return part:Clone()
		end)

		part.Archivable = previousArchivable

		if not ok or not overlay then
			return nil
		end

		-- Keep the original geometry (including R6 mesh variants), but remove
		-- textures, joints and attachments so this clone is purely visual.
		local overlayScale = 1.055
		local hasDataModelMesh = false

		for _, child in ipairs(overlay:GetChildren()) do
			if child:IsA("DataModelMesh") then
				hasDataModelMesh = true
				child.Scale = child.Scale * overlayScale
				child.VertexColor = Vector3.new(1, 1, 1)

				if child:IsA("FileMesh") then
					child.TextureId = ""
				end
			else
				child:Destroy()
			end
		end

		overlay.Name =
			"SelectedRegionOverlay_"
			.. part.Name

		overlay.CFrame = part.CFrame
		overlay.Size =
			hasDataModelMesh
			and part.Size
			or part.Size * overlayScale
		overlay.Color = Theme.Accent
		overlay.Material = Enum.Material.SmoothPlastic
		overlay.Transparency = 0.52
		overlay.Reflectance = 0
		overlay.Anchored = false
		overlay.Massless = true
		overlay.CanCollide = false
		overlay.CanTouch = false
		overlay.CanQuery = false
		overlay.CastShadow = false
		overlay.LocalTransparencyModifier = 0
		overlay.AssemblyLinearVelocity = Vector3.zero
		overlay.AssemblyAngularVelocity = Vector3.zero

		-- MeshPart textures would otherwise hide the translucent red tint.
		pcall(function()
			overlay.TextureID = ""
		end)

		overlay.Parent = world

		local weld = Instance.new("WeldConstraint")
		weld.Name = "SelectionOverlayWeld"
		weld.Part0 = part
		weld.Part1 = overlay
		weld.Parent = overlay

		return overlay
	end

	local function updatePreviewOverlay()
		clearSelectionOverlays()

		if not Preview.Model then
			return
		end

		local part = getPreviewPart(
			controls.SelectedPartName
			or Config.PrimaryBodyPartName
		)

		if part then
			local overlay = createSelectionOverlay(part)
			if overlay then
				Preview.SelectionOverlays[1] = overlay
			end
		end
	end

	local function loadCharacter()
		if not Runtime.Alive or not world.Parent then
			return
		end

		Preview.LoadGeneration += 1
		local generation = Preview.LoadGeneration

		local model =
			createPreviewModel()

		if not Runtime.Alive
			or not world.Parent
			or generation ~= Preview.LoadGeneration then

			if model then
				model:Destroy()
			end

			return
		end

		if not model then
			previewHint.Text =
				"Boneco indisponível. Renasça para tentar novamente."
			previewHint.TextColor3 = Theme.Warning
			return
		end

		clearWorld()
		previewHint.Text = "Toque em uma parte  •  Arraste para girar"
		previewHint.TextColor3 = Theme.Sub

		model.Name = "PreviewCharacter"

		-- Remove Animate/scripts before the preview ever enters PlayerGui.
		-- This prevents the generated Animate LocalScript from running.
		local animate =
			model:FindFirstChild(
				"Animate"
			)

		if animate then
			animate:Destroy()
		end

		sanitizeModel(model)
		model.Parent = world

		task.defer(function()
			if model.Parent ~= world
				or generation ~= Preview.LoadGeneration then

				return
			end

			placeModelFront(model)

			task.defer(function()
				if model.Parent ~= world
					or generation ~= Preview.LoadGeneration then

					return
				end

				Preview.Model = model
				frameModel(model)
				updatePreviewOverlay()
			end)
		end)
	end

	for rigName, control in pairs(controls.RigButtons) do
		control.Button.MouseButton1Click:Connect(function()
			if controls.RigMode == rigName then
				return
			end

			controls.RigMode = rigName
			Preview.Rotation = 180
			local partName = BodyRigProfiles.DefaultForRegion(
				rigName,
				Config.PrimaryBodyRegion
			)

			UI.SetPrimaryBodyPart(partName, {
				RigMode = rigName,
				Reason = "Modelo corporal alterado",
			})
			loadCharacter()
			UI.Toast("Boneco alterado para " .. rigName)
		end)
	end

	task.defer(loadCharacter)

	Runtime.Track(
		S.LocalPlayer.CharacterAdded:
		Connect(function()
			task.wait(0.45)

			if not Runtime.Alive or not world.Parent then
				return
			end

			loadCharacter()
		end)
	)

	-- One transparent interaction layer over the ViewportFrame. First use an
	-- exact ray against the visible body. If a finger lands just outside a
	-- thin limb, a small 2D nearest-limb area handles the miss. The torso has
	-- almost no extra padding, so it cannot steal arm or leg touches.
	local clickSurface = Util.New("TextButton", {
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Text = "",
		AutoButtonColor = false,
		ZIndex = 10,
	}, viewport)

	local function regionFromPart(part)
		if not part then
			return nil, nil
		end

		local region =
			PartToRegion[part.Name]

		if region then
			return part.Name, region
		end

		local accessory =
			part:FindFirstAncestorOfClass("Accessory")

		if accessory then
			local weld =
				part:FindFirstChild("AccessoryWeld")
				or part:FindFirstChildWhichIsA("Weld")

			local attached =
				weld and weld.Part1

			if attached then
				return
					attached.Name,
					PartToRegion[attached.Name]
			end
		end

		return nil, nil
	end

	local function rayFromScreen(screenPosition)
		local size =
			viewport.AbsoluteSize

		if size.X <= 1 or size.Y <= 1 then
			return nil, nil
		end

		local relative =
			Vector2.new(
				screenPosition.X
					-
					viewport.AbsolutePosition.X,

				screenPosition.Y
					-
					viewport.AbsolutePosition.Y
			)

		local x =
			(relative.X / size.X) * 2 - 1

		local y =
			1 - (relative.Y / size.Y) * 2

		local tanHalf =
			math.tan(
				math.rad(
					camera.FieldOfView * 0.5
				)
			)

		local aspect =
			size.X / size.Y

		local cameraDirection =
			Vector3.new(
				x * tanHalf * aspect,
				y * tanHalf,
				-1
			).Unit

		return
			camera.CFrame.Position,
			camera.CFrame:
				VectorToWorldSpace(
					cameraDirection
				)
	end

	local regionTapPadding = {
		Head = 7,
		Torso = 1,
		LeftArm = 9,
		RightArm = 9,
		LeftLeg = 8,
		RightLeg = 8,
	}

	local function previewPartVisible(part)
		if not Preview.Model or not part then
			return false
		end

		local direction = part.Position - camera.CFrame.Position
		if direction.Magnitude <= 0.001 then
			return true
		end

		local params = RaycastParams.new()
		params.FilterType = Enum.RaycastFilterType.Include
		params.FilterDescendantsInstances = {Preview.Model}
		params.IgnoreWater = true

		local ok, result = pcall(function()
			return world:Raycast(
				camera.CFrame.Position,
				direction * 1.02,
				params
			)
		end)

		-- Older clients may not expose WorldModel raycasts. In that case the
		-- geometric fallback remains available instead of disabling selection.
		if not ok or not result then
			return true
		end

		local hitPartName = regionFromPart(result.Instance)
		return result.Instance == part or hitPartName == part.Name
	end

	local function regionNearScreenPoint(screenPosition)
		local size = viewport.AbsoluteSize

		if size.X <= 1 or size.Y <= 1 then
			return nil
		end

		local tanHalf =
			math.tan(
				math.rad(camera.FieldOfView * 0.5)
			)

		local aspect = size.X / size.Y
		local viewportOrigin = viewport.AbsolutePosition
		local bestPartName = nil
		local bestRegion = nil
		local bestScore = math.huge
		local rigProfile =
			BodyRigProfiles[controls.RigMode]
			or BodyRigProfiles.R15

		for _, entry in ipairs(rigProfile.Parts) do
			local regionName = entry.Region
			local padding = regionTapPadding[regionName] or 4

			local part = getPreviewPart(entry.Name)
			if part and previewPartVisible(part) then
				local cameraPoint =
					camera.CFrame:PointToObjectSpace(part.Position)

				local depth = -cameraPoint.Z

				if depth > 0.01 then
					local normalizedX =
						cameraPoint.X / (depth * tanHalf * aspect)

					local normalizedY =
						cameraPoint.Y / (depth * tanHalf)

					local center = Vector2.new(
						viewportOrigin.X + (normalizedX + 1) * 0.5 * size.X,
						viewportOrigin.Y + (1 - normalizedY) * 0.5 * size.Y
					)

					local pixelsPerStud =
						size.Y / (2 * depth * tanHalf)

					local minimumRadius =
						regionName == "Torso" and 5 or 8

					local radiusX = math.max(
						math.max(part.Size.X, part.Size.Z)
							* 0.5
							* pixelsPerStud
							+ padding,
						minimumRadius
					)

					local radiusY = math.max(
						part.Size.Y * 0.5 * pixelsPerStud + padding,
						minimumRadius
					)

					local dx =
						(screenPosition.X - center.X) / radiusX

					local dy =
						(screenPosition.Y - center.Y) / radiusY

					local score = dx * dx + dy * dy

					if score <= 1 and score < bestScore then
						bestScore = score
						bestPartName = entry.Name
						bestRegion = regionName
					end
				end
			end
		end

		return bestPartName, bestRegion
	end

	local function selectPartAt(screenPosition)
		if not Preview.Model then
			return
		end

		local origin, direction = rayFromScreen(screenPosition)
		if not origin or not direction then
			return
		end

		local params = RaycastParams.new()
		params.FilterType = Enum.RaycastFilterType.Include
		params.FilterDescendantsInstances = {Preview.Model}
		params.IgnoreWater = true

		local ok, result = pcall(function()
			return world:Raycast(origin, direction * 100, params)
		end)

		local partName = nil
		local region = nil

		if ok and result then
			partName, region = regionFromPart(result.Instance)
		end

		if not partName or not region then
			partName, region = regionNearScreenPoint(screenPosition)
		end

		if partName and region then
			UI.SetPrimaryBodyPart(partName, {
				RigMode = controls.RigMode,
				Reason = "Prioridade alterada no boneco 3D",
			})

			UI.Toast(
				"Parte escolhida: "
				.. (PartLabels[partName] or regionNames[region] or partName)
			)
		end
	end

	local function previewInputMatches(activeInput, changedInput)
		if not activeInput then
			return false
		end

		if activeInput.UserInputType == Enum.UserInputType.Touch then
			return changedInput == activeInput
		end

		return activeInput.UserInputType == Enum.UserInputType.MouseButton1
			and changedInput.UserInputType == Enum.UserInputType.MouseMovement
	end

	clickSurface.InputBegan:Connect(function(input)
		if input.UserInputType ~= Enum.UserInputType.Touch
			and input.UserInputType ~= Enum.UserInputType.MouseButton1 then

			return
		end

		if Preview.DragInput and Preview.DragInput ~= input then
			return
		end

		Preview.DragInput = input
		Preview.DragStart = input.Position
		Preview.DragRotation = Preview.Rotation
		Preview.DragMoved = false
	end)

	Runtime.Track(S.UIS.InputChanged:Connect(function(input)
		if not previewInputMatches(Preview.DragInput, input)
			or not Preview.DragStart then

			return
		end

		local delta = input.Position - Preview.DragStart
		if Vector2.new(delta.X, delta.Y).Magnitude >= 6 then
			Preview.DragMoved = true
		end

		if Preview.DragMoved and Preview.Model then
			Preview.Rotation = (Preview.DragRotation + delta.X * 0.45) % 360
			Preview.Model:PivotTo(
				CFrame.new(0, 0, 0)
				* CFrame.Angles(0, math.rad(Preview.Rotation), 0)
			)
		end
	end))

	Runtime.Track(S.UIS.InputEnded:Connect(function(input)
		local matches = input == Preview.DragInput
			or (
				Preview.DragInput
				and Preview.DragInput.UserInputType == Enum.UserInputType.MouseButton1
				and input.UserInputType == Enum.UserInputType.MouseButton1
			)

		if not matches then
			return
		end

		local position = input.Position
		local finalDelta = Preview.DragStart and position - Preview.DragStart
		local shouldSelect = not Preview.DragMoved
			and input.UserInputState ~= Enum.UserInputState.Cancel
			and (not finalDelta or Vector2.new(finalDelta.X, finalDelta.Y).Magnitude < 6)
		Preview.DragInput = nil
		Preview.DragStart = nil
		Preview.DragMoved = false

		if shouldSelect then
			selectPartAt(position)
		end
	end))


	local detail = Util.New("Frame", {
		Position = UDim2.new(0.48, 2, 0, 12),
		Size = UDim2.new(0.52, -14, 1, -24),
		BackgroundColor3 = Theme.Card,
		BackgroundTransparency = 0.03,
		BorderSizePixel = 0,
	}, panel)
	Util.Corner(detail, 16)
	Util.Sheen(detail, 0.07)
	Util.Stroke(detail, Theme.BorderInner, 0.58, 1)
	Util.InnerHighlight(detail, 12, 0.91)

	local bodyLayoutMode = nil
	local function refreshBodyPanelLayout()
		local sideBySide = panel.AbsoluteSize.X >= 520
		local nextMode = sideBySide and "SIDE" or "STACK"
		if bodyLayoutMode == nextMode then
			return
		end

		bodyLayoutMode = nextMode
		if sideBySide then
			panel.Size = UDim2.new(1, 0, 0, 360)
			viewport.Position = UDim2.fromOffset(12, 12)
			viewport.Size = UDim2.new(0.48, -18, 1, -24)
			detail.Position = UDim2.new(0.48, 2, 0, 12)
			detail.Size = UDim2.new(0.52, -14, 1, -24)
		else
			panel.Size = UDim2.new(1, 0, 0, 640)
			viewport.Position = UDim2.fromOffset(12, 12)
			viewport.Size = UDim2.new(1, -24, 0, 290)
			detail.Position = UDim2.fromOffset(12, 314)
			detail.Size = UDim2.new(1, -24, 0, 314)
		end

		schedulePreviewFrame()
	end

	panel:GetPropertyChangedSignal("AbsoluteSize"):
		Connect(refreshBodyPanelLayout)
	task.defer(refreshBodyPanelLayout)

	Util.New("TextLabel", {
		Position = UDim2.fromOffset(14, 10),
		Size = UDim2.new(0.48, -4, 0, 18),
		BackgroundTransparency = 1,
		Text = "PARTE ESCOLHIDA",
		TextColor3 = Theme.Dim,
		Font = Enum.Font.GothamBold,
		TextSize = 8,
		TextXAlignment = Enum.TextXAlignment.Left,
	}, detail)

	controls.Title = Util.New("TextLabel", {
		Position = UDim2.fromOffset(14, 31),
		Size = UDim2.new(1, -28, 0, 27),
		BackgroundTransparency = 1,
		Text = "",
		TextColor3 = Theme.Text,
		Font = Enum.Font.GothamBold,
		TextSize = 10,
		TextXAlignment = Enum.TextXAlignment.Left,
	}, detail)
	Util.FitText(controls.Title, 7, 12)

	controls.Status = Util.New("TextLabel", {
		Position = UDim2.fromOffset(14, 59),
		Size = UDim2.new(1, -28, 0, 22),
		BackgroundTransparency = 1,
		Text = "",
		TextColor3 = Theme.Sub,
		Font = Enum.Font.Gotham,
		TextSize = 8,
		TextXAlignment = Enum.TextXAlignment.Left,
	}, detail)
	Util.FitText(controls.Status, 7, 10)

	controls.RegionChip = Util.New("TextLabel", {
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -14, 0, 10),
		Size = UDim2.new(0.48, 0, 0, 25),
		BackgroundColor3 = Theme.Chip,
		BorderSizePixel = 0,
		Text = "PRINCIPAL",
		TextColor3 = Theme.Sub,
		Font = Enum.Font.GothamBold,
		TextSize = 8,
	}, detail)
	Util.FitText(controls.RegionChip, 7, 10)

	Util.Corner(
		controls.RegionChip,
		999
	)

	controls.SyncStatus = Util.New("TextLabel", {
		Position = UDim2.fromOffset(14, 88),
		Size = UDim2.new(1, -28, 0, 31),
		BackgroundColor3 = Theme.CardActive,
		BorderSizePixel = 0,
		Text = "USADO EM TODAS AS ABAS",
		TextColor3 = Theme.Text,
		Font = Enum.Font.GothamBold,
		TextSize = 9,
	}, detail)
	Util.Corner(controls.SyncStatus, 999)
	Util.Gradient(
		controls.SyncStatus,
		Theme.AccentSoft,
		Theme.AccentDeep,
		90
	)
	Util.Stroke(controls.SyncStatus, Theme.Accent2, 0.26, 1)
	Util.FitText(controls.SyncStatus, 7, 11)

	controls.RegionEnabled =
		UI.CreateToggle(
			detail,
			"Região principal",
			"A região escolhida fica sempre ativa. Toque em outra parte para mudar.",
			{Organizable = false, Scalable = false}
		)

	controls.RegionEnabled.Card.Position =
		UDim2.fromOffset(
			14,
			128
		)

	controls.RegionEnabled.Card.Size =
		UDim2.new(
			1,
			-28,
			0,
			76
		)

	controls.Weight = UI.CreateSlider(
		detail,
		"Preferência desta região",
		0,
		100,
		Config.BodyRegionWeights[controls.SelectedRegion] or 100,
		"%",
		function(value)
			Config.BodyRegionWeights[controls.SelectedRegion] =
				math.floor(value + 0.5)
			Aim.MarkAssistantCustomized()
		end,
		{
			Organizable = false,
			Scalable = false,
			Description = "Quanto maior, maior a preferência por esta região.",
			Help = "O peso compara as regiões disponíveis. Com Priorizar a parte escolhida ligado, a parte principal vem antes desses pesos.",
		}
	)
	controls.Weight.Card.Position = UDim2.fromOffset(14, 210)
	controls.Weight.Card.Size = UDim2.new(1, -28, 0, 91)

	local options = UI.CreateExpandableGroup(
		page,
		"AJUSTES AVANÇADOS",
		"Abra para escolher o que acontece quando a parte fica coberta.",
		false
	)

	controls.Exact = UI.CreateToggle(
		options,
		"Manter no centro",
		"Mantém a mira no centro da parte escolhida."
	)

	controls.Strict = UI.CreateToggle(
		options,
		"Priorizar a parte escolhida",
		"Tenta sua parte principal antes de procurar outra."
	)

	controls.MultiPoint = UI.CreateToggle(
		options,
		"Buscar outro ponto visível",
		"Se o centro estiver coberto, tenta outro ponto da mesma parte."
	)

	controls.Fallback = UI.CreateToggle(
		options,
		"Tentar outra parte",
		"Se a principal não estiver disponível, tenta outra parte liberada.",
		{
			Help = "Essa opção trabalha junto com Priorizar a parte escolhida. Se o alvo principal estiver coberto, a mira tenta outra parte que você deixou disponível.",
		}
	)

	controls.LongRange = UI.CreateToggle(
		options,
		"Corrigir altura da cabeça",
		"Evita mirar baixo na cabeça quando o jogador está muito longe.",
		{
			Help = "Só faz diferença quando Cabeça está escolhida e Manter no centro está ativado. A opção Compensar longa distância, na aba Mira, controla a força geral do movimento.",
		}
	)

	controls.AllowedRegions = {}
	for _, regionName in ipairs(BodyRegionOrder) do
		local selectedRegion = regionName
		local regionLabel = BodyRegions[selectedRegion].Label
		local control = UI.CreateToggle(options, "Usar " .. string.lower(regionLabel),
			"Permite usar esta região quando a mira procurar outra parte.",
			{Id = "body.allowed_region." .. selectedRegion})
		controls.AllowedRegions[selectedRegion] = control
		control.Card.MouseButton1Click:Connect(function()
			if selectedRegion == Config.PrimaryBodyRegion then
				UI.Toast("A região principal fica sempre disponível. Escolha outra parte para poder desativá-la.")
				return
			end
			Config.BodyRegionEnabled[selectedRegion] = not Config.BodyRegionEnabled[selectedRegion]
			Aim.MarkAssistantCustomized()
			Aim.ClearCurrentTarget("Regiões disponíveis foram alteradas")
			controls.Refresh()
		end)
	end

	function controls.Refresh()
		local rigName, partName, region = BodyRigProfiles.Normalize(
			Config.BodyRigMode,
			Config.PrimaryBodyPartName,
			Config.PrimaryBodyRegion
		)
		Config.BodyRigMode = rigName
		Config.PrimaryBodyPartName = partName
		Config.PrimaryBodyRegion = region
		controls.RigMode = rigName
		controls.SelectedPartName = partName
		controls.SelectedRegion = region
		controls.LastRigMode = rigName
		controls.LastPrimaryPartName = partName
		controls.LastPrimaryRegion = region
		Config.BodyRegionEnabled =
			Config.BodyRegionEnabled or {}

		Config.BodyRegionWeights =
			Config.BodyRegionWeights or {}

		local enabled =
			Config.BodyRegionEnabled[region] == true

		controls.Title.Text =
			PartLabels[partName]
			or regionNames[region]
			or (partName and tostring(partName))
			or "PARTE"

		controls.Status.Text =
			rigName
			.. "  •  PRINCIPAL  •  "
			..
			(enabled and "ATIVA" or "DESATIVADA")

		if controls.RegionChip then
			controls.RegionChip.Text = rigName .. " • PRINCIPAL"
			controls.RegionChip.BackgroundColor3 = Theme.AccentSoft
			controls.RegionChip.TextColor3 = Theme.Accent2
		end

		controls.SyncStatus.Text = "USADO EM TODAS AS ABAS"
		controls.SyncStatus.BackgroundColor3 = Theme.CardActive

		for name, control in pairs(controls.RigButtons) do
			local active = name == rigName
			control.Button.BackgroundColor3 =
				active and Theme.CardActive or Theme.Card
			control.Button.TextColor3 =
				active and Theme.Text or Theme.Sub
			control.Stroke.Color =
				active and Theme.Accent2 or Theme.BorderSoft
			control.Stroke.Transparency = active and 0.12 or 0.64
		end

		UI.SetToggle(
			controls.RegionEnabled,
			enabled
		)

		controls.Weight:SetValue(
			Config.BodyRegionWeights[region] or 0,
			false
		)

		UI.SetToggle(controls.Exact, Config.ExactBodyAim)
		UI.SetToggle(controls.Strict, Config.StrictBodyRegion)
		UI.SetToggle(controls.MultiPoint, Config.MultiPointBodyAim)
		UI.SetToggle(controls.Fallback, Config.BodyFallback)
		UI.SetToggle(controls.LongRange, Config.LongRangeCorrection)
		UI.SetControlAvailable(controls.RegionEnabled, false,
			"A região principal fica sempre disponível. Ajuste as outras regiões em Avançado.")
		for regionName, control in pairs(controls.AllowedRegions) do
			UI.SetToggle(control, Config.BodyRegionEnabled[regionName] == true)
			UI.SetControlAvailable(control, regionName ~= Config.PrimaryBodyRegion,
				"A região principal fica sempre disponível.")
		end

		updatePreviewOverlay()
	end

	controls.RegionEnabled.Card.MouseButton1Click:
		Connect(function()
			local region =
				controls.SelectedRegion

			Config.BodyRegionEnabled =
				Config.BodyRegionEnabled or {}

			if Config.PrimaryBodyRegion == region then
				UI.Toast("A região principal fica sempre disponível. Veja as outras regiões em Avançado.")
				return
			else
				Config.BodyRegionEnabled[region] =
					not (
						Config.BodyRegionEnabled[region]
						== true
					)
			end

			Aim.MarkAssistantCustomized()
			Aim.ClearCurrentTarget("Regiões disponíveis foram alteradas")
			controls.Refresh()
		end)

	controls.Exact.Card.MouseButton1Click:Connect(function()
		Config.ExactBodyAim = not Config.ExactBodyAim
		Aim.MarkAssistantCustomized()
		Aim.ClearCurrentTarget("Modo de precisão alterado")
		controls.Refresh()
	end)

	controls.Strict.Card.MouseButton1Click:Connect(function()
		Config.StrictBodyRegion = not Config.StrictBodyRegion
		Aim.MarkAssistantCustomized()
		Aim.ClearCurrentTarget("Prioridade corporal alterada")
		controls.Refresh()
	end)

	controls.MultiPoint.Card.MouseButton1Click:Connect(function()
		Config.MultiPointBodyAim = not Config.MultiPointBodyAim
		Aim.MarkAssistantCustomized()
		Aim.ClearCurrentTarget("Pontos de mira alterados")
		controls.Refresh()
	end)

	controls.Fallback.Card.MouseButton1Click:Connect(function()
		Config.BodyFallback = not Config.BodyFallback
		Aim.MarkAssistantCustomized()
		Aim.ClearCurrentTarget("Tentativa em outra parte foi alterada")
		controls.Refresh()
	end)

	controls.LongRange.Card.MouseButton1Click:Connect(function()
		Config.LongRangeCorrection = not Config.LongRangeCorrection
		Aim.MarkAssistantCustomized()
		controls.Refresh()
	end)

	-- This is the view-only half of body synchronization. Configuration is
	-- always changed by UI.SetPrimaryBodyRegion/Part first, so no page can keep
	-- a private selection that disagrees with the aim engine.
	State.UI.SyncBodySelection = function(partName, rigName)
		local previousRig = controls.RigMode
		rigName, partName, controls.SelectedRegion =
			BodyRigProfiles.Normalize(
				rigName or Config.BodyRigMode,
				partName,
				Config.PrimaryBodyRegion
			)

		controls.RigMode = rigName
		controls.SelectedPartName = partName
		controls.LastRigMode = rigName
		controls.LastPrimaryPartName = partName
		controls.LastPrimaryRegion = controls.SelectedRegion
		controls.Refresh()

		if previousRig ~= rigName then
			Preview.Rotation = 180
			task.defer(loadCharacter)
		end

		return true
	end

	State.UI.SelectBodyRegion = function(region)
		return UI.SetPrimaryBodyRegion(region, {
			Reason = "Foco corporal alterado",
		})
	end

	State.UI.SelectBodyPart = function(partName, rigName)
		return UI.SetPrimaryBodyPart(partName, {
			RigMode = rigName,
			Reason = "Parte corporal alterada",
		})
	end

	State.UI.ReloadBodyPreview = loadCharacter

	State.UI.RefreshBodyControls = controls.Refresh
	controls.Refresh()
	return page
end

function UI.SettingsSearchKey(value)
	local text = string.lower(tostring(value or ""))
	local accents = { ["á"] = "a", ["à"] = "a", ["ã"] = "a", ["â"] = "a", ["Á"] = "a", ["À"] = "a", ["Ã"] = "a", ["Â"] = "a",
		["é"] = "e", ["ê"] = "e", ["É"] = "e", ["Ê"] = "e", ["í"] = "i", ["Í"] = "i", ["ó"] = "o", ["ô"] = "o", ["õ"] = "o",
		["Ó"] = "o", ["Ô"] = "o", ["Õ"] = "o", ["ú"] = "u", ["ü"] = "u", ["Ú"] = "u", ["Ü"] = "u", ["ç"] = "c", ["Ç"] = "c" }
	return (text:gsub("[\194-\244][\128-\191]*", accents))
end

function UI.SettingsText(parent, text, position, size, fontSize, color, bold)
	return Util.New("TextLabel", {
		Position = position, Size = size, BackgroundTransparency = 1, Text = text,
		TextColor3 = color or Theme.Text, Font = bold and Enum.Font.GothamBold or Enum.Font.Gotham,
		TextSize = fontSize or 9, TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd,
	}, parent)
end

function UI.SettingsGlyph(parent, kind, size)
	local box = Util.New("Frame", {
		Size = UDim2.fromOffset(size, size), BackgroundColor3 = Theme.AccentSoft,
		BackgroundTransparency = 0.35, BorderSizePixel = 0,
	}, parent)
	Util.Corner(box, 10)
	local function part(x, y, w, h, color, hollow)
		local shape = Util.New("Frame", {
			Position = UDim2.fromScale(x, y), Size = UDim2.fromScale(w, h),
			BackgroundColor3 = color or Theme.Accent2, BackgroundTransparency = hollow and 1 or 0,
			BorderSizePixel = 0,
		}, box)
		Util.Corner(shape, 999)
		if hollow then Util.Stroke(shape, Theme.Accent2, 0.12, 1) end
	end
	if kind == "MENU" then
		part(.25,.25,.18,.18); part(.57,.25,.18,.18); part(.25,.57,.18,.18); part(.57,.57,.18,.18)
	elseif kind == "MOBILE" then
		part(.33,.18,.34,.64,nil,true); part(.43,.69,.14,.04)
	elseif kind == "ORDER" then
		part(.25,.29,.5,.07); part(.25,.47,.36,.07); part(.25,.65,.44,.07)
	else
		part(.23,.27,.54,.47,nil,true); part(.37,.36,.26,.06); part(.37,.5,.26,.06)
	end
	return box
end

function UI.SettingsGroup(parent, title, subtitle, id)
	local order = (parent:GetAttribute("AAPSettingsGroupCount") or 0) + 1
	parent:SetAttribute("AAPSettingsGroupCount", order)
	local shell = Util.New("Frame", {
		Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1, BorderSizePixel = 0, LayoutOrder = order * 10,
	}, parent)
	Util.New("UIListLayout", {Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder}, shell)
	local header = Util.New("Frame", {
		Size = UDim2.new(1, 0, 0, subtitle and 40 or 24), BackgroundTransparency = 1, LayoutOrder = -10,
	}, shell)
	UI.SettingsText(header, title, UDim2.fromOffset(2, 1), UDim2.new(1, -4, 0, 18), 10, Theme.Text, true)
	if subtitle then
		UI.SettingsText(header, subtitle, UDim2.fromOffset(2, 22), UDim2.new(1, -4, 0, 15), 8, Theme.Sub)
	end
	local content = Util.New("Frame", {
		Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1, BorderSizePixel = 0,
	}, shell)
	Util.New("UIListLayout", {Padding = UDim.new(0, 7), SortOrder = Enum.SortOrder.LayoutOrder}, content)
	if id then UI.RegisterOrganizerContainer(content, id) end
	return content, shell
end

function UI.StyleSettingsControl(control)
	local card = control.Card
	local cycle = typeof(control.Value) == "Instance"
	local baseHeight = cycle and 104 or control.Switch and 82 or 104
	local slot = control.Record and control.Record.Card or card
	for _, entry in ipairs(UI.ScalableControls) do
		if entry.Card == slot then entry.BaseHeight = baseHeight; break end
	end
	slot.Size = UDim2.new(slot.Size.X.Scale, slot.Size.X.Offset, 0, math.floor(baseHeight * Config.ControlScale + .5))
	if control.Record then control.Record.OriginalSize = slot.Size end
	card.BackgroundTransparency = 0.12
	if control.Title then
		control.Title.Font = Enum.Font.GothamMedium
	end
	if cycle then
		control.Title.Size = UDim2.new(1, control.Help and -54 or -28, 0, 18)
		control.Title.Position = UDim2.fromOffset(14, 8)
		Util.FitText(control.Title, 8, 11)
		control.Description.Position = UDim2.fromOffset(14, 30)
		control.Description.Size = UDim2.new(1, -28, 0, 18)
		control.Value.AnchorPoint = Vector2.new(0, 1)
		control.Value.Position = UDim2.new(0, 14, 1, -8)
		control.Value.Size = UDim2.new(1, -28, 0, 26)
		control.Value.BackgroundColor3 = Theme.Surface3
		control.Value.TextColor3 = Theme.Accent2
		Util.FitText(control.Value, 8, 10)
		if control.Help then control.Help.Position = UDim2.new(1, -10, 0, 3) end
	else
		control.Description.Size = UDim2.new(1, -28, 0, control.Switch and 25 or 18)
	end
end

function UI.CreateSettingsWorkspace(page)
	local view = {Page = page, Categories = {}, Tiles = {}, Entries = {}, Scroll = {}, Active = "HOME", Display = "HOME", Generation = 0, LastSearchText = ""}
	page:SetAttribute("AAPHideScrollCue", true)
	page.Position = UDim2.fromOffset(3, 77)
	page.Size = UDim2.new(1, -6, 1, -80)
	page.ScrollBarThickness = 3
	local toolbar = Util.New("Frame", {
		Name = "AAP_SettingsToolbar", Position = UDim2.fromOffset(7, 4),
		Size = UDim2.new(1, -22, 0, 66), BackgroundTransparency = 1,
		Visible = page.Visible,
	}, page.Parent)
	view.Toolbar = toolbar
	view.Back = Util.New("TextButton", {
		Size = UDim2.fromOffset(66, 27), BackgroundColor3 = Theme.Surface3, BackgroundTransparency = .25,
		BorderSizePixel = 0, Text = "‹  Início", TextColor3 = Theme.Sub, Font = Enum.Font.GothamMedium,
		TextSize = 9, AutoButtonColor = false, Visible = false,
	}, toolbar)
	Util.Corner(view.Back, 10)
	UI.TouchFeedback(view.Back)
	view.Title = UI.SettingsText(toolbar, "Configurações", UDim2.fromOffset(2, 2), UDim2.new(1, -4, 0, 24), 13, Theme.Text, true)
	Util.FitText(view.Title, 10, 14)
	local searchBox = Util.New("Frame", {
		Position = UDim2.fromOffset(0, 34), Size = UDim2.new(1, 0, 0, 30),
		BackgroundColor3 = Theme.Surface3, BackgroundTransparency = .3, BorderSizePixel = 0,
	}, toolbar)
	Util.Corner(searchBox, 10)
	Util.Stroke(searchBox, Theme.BorderSoft, .65, 1)
	view.Search = Util.New("TextBox", {
		Position = UDim2.fromOffset(12, 0), Size = UDim2.new(1, -46, 1, 0), BackgroundTransparency = 1,
		Text = "", PlaceholderText = "Buscar ajuste...", PlaceholderColor3 = Theme.Sub,
		TextColor3 = Theme.Text, Font = Enum.Font.Gotham, TextSize = 9,
		TextXAlignment = Enum.TextXAlignment.Left, ClearTextOnFocus = false, MultiLine = false,
	}, searchBox)
	view.Clear = Util.New("TextButton", {
		Position = UDim2.new(1, -32, 0, 0), Size = UDim2.fromOffset(32, 30), BackgroundTransparency = 1,
		Text = "×", TextColor3 = Theme.Sub, Font = Enum.Font.Gotham, TextSize = 14,
		Visible = false, AutoButtonColor = false,
	}, searchBox)
	local definitions = {
		{Key = "MENU", Label = "Aparência", Detail = "Cores, formato e tamanho"},
		{Key = "MOBILE", Label = "Celular", Detail = "Atalhos e troca por gesto"},
		{Key = "ORDER", Label = "Organização", Detail = "Ordem das opções e testes"},
		{Key = "FILES", Label = "Salvos", Detail = "Guardar e carregar ajustes"},
	}
	view.Definitions = definitions
	function view:AddCategory(key)
		local holder = Util.New("Frame", {
			Name = "AAP_Settings_" .. key, Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, BorderSizePixel = 0, Visible = false,
		}, page)
		Util.New("UIListLayout", {Padding = UDim.new(0, 16), SortOrder = Enum.SortOrder.LayoutOrder}, holder)
		self.Categories[key] = holder
		return holder
	end
	local home = view:AddCategory("HOME")
	for _, definition in ipairs(definitions) do view:AddCategory(definition.Key) end
	local summary = Util.New("Frame", {
		Name = "AAP_SettingsSummary", Size = UDim2.new(1, 0, 0, 88),
		BackgroundColor3 = Theme.CardActive, BackgroundTransparency = .13, BorderSizePixel = 0, LayoutOrder = -10,
	}, home)
	Util.Corner(summary, 14)
	Util.Stroke(summary, Theme.AccentSoft, .45, 1)
	UI.SettingsText(summary, "SEU MENU", UDim2.fromOffset(14, 11), UDim2.new(1, -145, 0, 13), 8, Theme.Accent2, true)
	view.SummaryTitle = UI.SettingsText(summary, "", UDim2.fromOffset(14, 31), UDim2.new(1, -145, 0, 18), 11, Theme.Text, true)
	Util.FitText(view.SummaryTitle, 8, 12)
	view.SummaryDetail = UI.SettingsText(summary, "", UDim2.fromOffset(14, 57), UDim2.new(1, -145, 0, 16), 8, Theme.Sub)
	local preview = Util.New("Frame", {
		Position = UDim2.new(1, -118, 0, 14), Size = UDim2.fromOffset(104, 60),
		BackgroundColor3 = Theme.Surface2, BorderSizePixel = 0,
	}, summary)
	Util.Corner(preview, 10)
	Util.Stroke(preview, Theme.BorderSoft, .3, 1)
	view.PreviewParts = {}
	for i = 1, 4 do
		local tab = Util.New("Frame", {
			Position = UDim2.fromOffset(8 + (i - 1) * 23, 9), Size = UDim2.fromOffset(18, 5),
			BackgroundColor3 = i == 1 and Theme.Accent or Theme.Muted, BackgroundTransparency = i == 1 and 0 or .5,
			BorderSizePixel = 0,
		}, preview)
		Util.Corner(tab, 999)
		if i == 1 then view.PreviewParts.Tab = tab end
	end
	for i = 1, 2 do
		local row = Util.New("Frame", {
			Position = UDim2.fromOffset(8, 23 + (i - 1) * 15), Size = UDim2.fromOffset(88, 10),
			BackgroundColor3 = Theme.Surface3, BorderSizePixel = 0,
		}, preview)
		Util.Corner(row, 999)
		local knob = Util.New("Frame", {
			Position = UDim2.fromOffset(72, 3), Size = UDim2.fromOffset(10, 4),
			BackgroundColor3 = Theme.Accent2, BorderSizePixel = 0,
		}, row)
		Util.Corner(knob, 999)
		view.PreviewParts[i] = knob
	end
	local tiles = Util.New("Frame", {
		Size = UDim2.new(1, 0, 0, 216), BackgroundTransparency = 1, BorderSizePixel = 0,
	}, home)
	view.TileHolder = tiles
	for _, definition in ipairs(definitions) do
		local card = Util.New("TextButton", {
			BackgroundColor3 = Theme.Card, BackgroundTransparency = .08, BorderSizePixel = 0,
			Text = "", AutoButtonColor = false,
		}, tiles)
		Util.Corner(card, 12)
		Util.Stroke(card, Theme.BorderSoft, .64, 1)
		local glyph = UI.SettingsGlyph(card, definition.Key, 28)
		glyph.Position = UDim2.fromOffset(12, 12)
		local title = UI.SettingsText(card, definition.Label, UDim2.fromOffset(49, 15), UDim2.new(1, -61, 0, 18), 10, Theme.Text, true)
		Util.FitText(title, 8, 11)
		UI.SettingsText(card, definition.Detail, UDim2.fromOffset(12, 50), UDim2.new(1, -24, 0, 16), 8, Theme.Sub)
		local state = UI.SettingsText(card, "", UDim2.fromOffset(12, 77), UDim2.new(1, -40, 0, 14), 8, Theme.Accent2)
		UI.SettingsText(card, "›", UDim2.new(1, -24, 0, 74), UDim2.fromOffset(16, 18), 14, Theme.Sub)
		view.Tiles[definition.Key] = {Card = card, State = state}
		UI.TouchFeedback(card)
		card.Activated:Connect(function() view.Show(definition.Key, false) end)
	end
	local results = view:AddCategory("SEARCH")
	view.Results = results
	view.NoResults = UI.SettingsText(results, "Nenhum ajuste encontrado. Tente outro nome.", UDim2.new(), UDim2.new(1, 0, 0, 52), 9, Theme.Sub)
	view.NoResults.TextWrapped = true
	view.NoResults.Visible = false
	local function rememberScroll()
		view.Scroll[view.Display] = page.CanvasPosition.Y
	end
	local function showOnly(key)
		for categoryKey, holder in pairs(view.Categories) do holder.Visible = categoryKey == key end
		view.Display = key
		view.Back.Visible = key ~= "HOME"
		view.Title.Position = UDim2.fromOffset(key == "HOME" and 2 or 76, 2)
		view.Title.Size = UDim2.new(1, key == "HOME" and -4 or -78, 0, 24)
		view.Title.Text = key == "HOME" and "Configurações" or key == "SEARCH" and "Resultados" or ""
		for _, definition in ipairs(definitions) do if definition.Key == key then view.Title.Text = definition.Label end end
	end
	function view.Show(key, resetScroll)
		if not Runtime.Alive or not page.Parent then return end
		if not view.Categories[key] or key == "SEARCH" then key = "HOME" end
		rememberScroll()
		view.Generation += 1
		view.LastSearchText = ""
		view.IgnoreSearch = true; view.Search.Text = ""; view.IgnoreSearch = false
		view.Clear.Visible = false
		view.Search:ReleaseFocus(false)
		view.Active = key
		showOnly(key)
		if resetScroll then view.Scroll[key] = 0 end
		local generation = view.Generation
		task.defer(function()
			S.RunService.Heartbeat:Wait()
			if Runtime.Alive and page.Parent and generation == view.Generation then
				page.CanvasPosition = Vector2.new(0, view.Scroll[key] or 0)
			end
		end)
	end
	function view:Reveal(entry)
		if entry.Open then entry.Open() end
		local target = entry.Control.Record and entry.Control.Record.Card or entry.Control.Card
		local destination = UI.GetPageForObject(target)
		if destination and destination ~= page then
			UI.ShowPage(destination)
		else
			destination = page
			local categoryKey = entry.Category
			local ancestor = target
			while ancestor and ancestor ~= page do
				for key, holder in pairs(self.Categories) do if holder == ancestor then categoryKey = key end end
				ancestor = ancestor.Parent
			end
			self.Show(categoryKey, false)
		end
		self.Generation += 1
		local generation = self.Generation
		task.defer(function()
			task.defer(function()
				S.RunService.Heartbeat:Wait()
				if not Runtime.Alive or generation ~= self.Generation or not target.Parent or not destination.Parent then return end
				local offset = target.AbsolutePosition.Y - destination.AbsolutePosition.Y + destination.CanvasPosition.Y - 8
				destination.CanvasPosition = Vector2.new(0, math.max(offset, 0))
				local outline = Util.New("Frame", {Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, BorderSizePixel = 0, ZIndex = 32}, entry.Control.Card)
				Util.Corner(outline, 12)
				Util.Stroke(outline, Theme.Accent2, .1, 2)
				task.delay(1.2, function() if outline.Parent then outline:Destroy() end end)
			end)
		end)
	end
	function view:AddSetting(category, control, words, open, title)
		local label = title or control.Title and control.Title.Text or "Ajuste"
		local entry = {Category = category, Control = control, Title = label, Open = open,
			SearchText = UI.SettingsSearchKey(label .. " " .. (words or "") .. " " .. (control.OriginalDescription or ""))}
		local row = Util.New("TextButton", {
			Size = UDim2.new(1, 0, 0, 62), BackgroundColor3 = Theme.Card, BackgroundTransparency = .10,
			BorderSizePixel = 0, Text = "", AutoButtonColor = false, Visible = false, LayoutOrder = #self.Entries + 1,
		}, results)
		Util.Corner(row, 12)
		Util.Stroke(row, Theme.BorderSoft, .75, 1)
		UI.SettingsText(row, label, UDim2.fromOffset(12, 10), UDim2.new(1, -46, 0, 18), 10, Theme.Text, true)
		local categoryLabel = category
		for _, d in ipairs(definitions) do if d.Key == category then categoryLabel = d.Label end end
		UI.SettingsText(row, categoryLabel, UDim2.fromOffset(12, 35), UDim2.new(1, -46, 0, 15), 8, Theme.Sub)
		UI.SettingsText(row, "›", UDim2.new(1, -26, 0, 20), UDim2.fromOffset(18, 20), 15, Theme.Accent2)
		UI.TouchFeedback(row)
		row.Activated:Connect(function() self:Reveal(entry) end)
		entry.Result = row
		self.Entries[#self.Entries + 1] = entry
	end
	function view.RefreshSearch()
		local query = UI.SettingsSearchKey(view.Search.Text):match("^%s*(.-)%s*$")
		view.Clear.Visible = query ~= ""
		if query == "" then view.Show(view.Active, false); return end
		if view.Display ~= "SEARCH" then rememberScroll() end
		showOnly("SEARCH")
		local count = 0
		for _, entry in ipairs(view.Entries) do
			local slot = entry.Control.Record and entry.Control.Record.Card or entry.Control.Card
			local matches = slot.Parent ~= nil and slot.Visible
			for word in query:gmatch("%S+") do if not string.find(entry.SearchText, word, 1, true) then matches = false; break end end
			entry.Result.Visible = matches
			if matches then count += 1 end
		end
		view.NoResults.Visible = count == 0
		view.ResultCount = count
		page.CanvasPosition = Vector2.zero
	end
	view.Search:GetPropertyChangedSignal("Text"):Connect(function()
		if view.IgnoreSearch or view.Search.Text == view.LastSearchText then return end
		view.LastSearchText = view.Search.Text
		view.Generation += 1
		local generation = view.Generation
		task.delay(.08, function()
			if Runtime.Alive and page.Parent and generation == view.Generation then view.RefreshSearch() end
		end)
	end)
	view.Clear.Activated:Connect(function() view.Show(view.Active, false) end)
	view.Back.Activated:Connect(function() view.Show("HOME", false) end)
	page:GetPropertyChangedSignal("Visible"):Connect(function()
		toolbar.Visible = page.Visible
		if not page.Visible then view.Search:ReleaseFocus(false) end
	end)
	local function layoutTiles()
		local columns = tiles.AbsoluteSize.X >= 350 and 2 or 1
		for index, definition in ipairs(definitions) do
			local column, row = (index - 1) % columns, math.floor((index - 1) / columns)
			local card = view.Tiles[definition.Key].Card
			card.Position = UDim2.new(column / columns, column == 0 and 0 or 4, 0, row * 112)
			card.Size = UDim2.new(1 / columns, columns == 1 and 0 or -4, 0, 104)
		end
		tiles.Size = UDim2.new(1, 0, 0, math.ceil(#definitions / columns) * 112 - 8)
		local compact = summary.AbsoluteSize.X < 300
		preview.Visible = not compact
		view.SummaryTitle.Size = UDim2.new(1, compact and -28 or -145, 0, 18)
		view.SummaryDetail.Size = UDim2.new(1, compact and -28 or -145, 0, 16)
	end
	tiles:GetPropertyChangedSignal("AbsoluteSize"):Connect(layoutTiles)
	layoutTiles()
	function view.Refresh()
		local theme = ThemePresets[Config.UITheme] or ThemePresets.RED
		view.SummaryTitle.Text = theme.Label
		view.SummaryDetail.Text = tostring(math.floor(Config.MenuScale * 100 + .5)) .. "% · " .. ((MENU_LAYOUT_PRESETS[Config.MenuLayoutStyle] or MENU_LAYOUT_PRESETS.BALANCED).Label)
		view.Tiles.MENU.State.Text = theme.Label
		view.Tiles.MOBILE.State.Text = Config.MobileFriendlySwitch and "Troca por gesto ativada" or "Troca por gesto desativada"
		view.Tiles.ORDER.State.Text = State.UI.LayoutEditMode and "Editando a ordem" or "Arraste para organizar"
		view.Tiles.FILES.State.Text = tostring(view.SavedCount or 0) .. " configurações"
	end
	State.UI.SettingsWorkspace = view
	State.UI.ShowSettingsCategory = view.Show
	return view
end

function Pages.BuildEngine()
	local page = UI.CreatePage("Engine")
	local controls = {}
	local view = UI.CreateSettingsWorkspace(page)
	local menuCategory = view.Categories.MENU
	local mobileCategory = view.Categories.MOBILE
	local orderCategory = view.Categories.ORDER
	local filesCategory = view.Categories.FILES
	local refreshSettingsCategoryButtons = view.Refresh
	local showSettingsCategory = view.Show
	local aimCategory = State.UI.AimAdvancedContainer
	if not aimCategory then
		aimCategory = Util.New("Frame", {Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
			BackgroundTransparency = 1, Visible = false}, page)
		Util.New("UIListLayout", {Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder}, aimCategory)
	end

	UI.Section(
		aimCategory,
		"MOVIMENTO E CORREÇÃO",
		"Use estes controles quando quiser ajustar a mira além dos perfis prontos."
	)

	local grid = UI.Stack(aimCategory)

	controls.Horizontal =
		UI.CreateSlider(
			grid,
			"Correção lateral",
			0,
			100,
			Config.HorizontalStrength,
			"%",
			function(value)
				Config.HorizontalStrength =
					math.floor(value + 0.5)
				Aim.MarkAssistantCustomized()
			end
		)

	controls.Vertical =
		UI.CreateSlider(
			grid,
			"Correção vertical",
			0,
			100,
			Config.VerticalStrength,
			"%",
			function(value)
				Config.VerticalStrength =
					math.floor(value + 0.5)
				Aim.MarkAssistantCustomized()
			end
		)

	controls.Distance =
		UI.CreateToggle(
			grid,
			"Compensar longa distância",
			"Mantém a correção mais firme quando o jogador está muito longe."
		)

	controls.Curve =
		UI.CreateCycle(
			grid,
			"Resposta da mira",
			"Adaptativa desacelera perto do alvo. Constante mantém a mesma velocidade."
		)

	controls.Profile =
		UI.CreateCycle(
			grid,
			"Ajuste fino da arma",
			"Muda só a resposta da arma. Para configurar tudo de uma vez, use Perfis.",
			{
				Help = "Este atalho altera apenas o comportamento usado para acompanhar disparos. A aba Perfis também ajusta FOV, precisão, suavidade e parte do corpo.",
			}
		)

	local mobileSupport = UI.SettingsGroup(mobileCategory, "Atalhos na tela", "Acesso à mira mesmo com o menu fechado.", "Engine:Stack1")

	controls.MobileQuick =
		UI.CreateToggle(
			mobileSupport,
			"Mostrar atalhos na tela",
			"Exibe os botões da mira fora do menu."
		)

	controls.MobileLock =
		UI.CreateToggle(
			mobileSupport,
			"Travar atalhos no lugar",
			"Evita mover os botões sem querer."
		)

	local swipeSupport, swipeShell = UI.SettingsGroup(mobileCategory, "Troca de alvo por gesto", "Escolha outro jogador com um deslize.", "Engine:Gestures")
	controls.MobileFriendly =
		UI.CreateToggle(
			swipeSupport,
			"Troca de alvo por gesto",
			"Deslize na direção do próximo jogador.",
			{
				Help = "Puxe para a direita para escolher um alvo à direita, ou para a esquerda para voltar. Você pode continuar arrastando para trocar de novo. Parar o dedo mantém o alvo. Use Inverter gesto se preferir o sentido contrário.",
			}
		)
	local mobileFriendlyVisible = S.UIS.TouchEnabled == true
	controls.MobileFriendly.Card.Visible = mobileFriendlyVisible
	if controls.MobileFriendly.Record then
		controls.MobileFriendly.Record.Card.Visible = mobileFriendlyVisible
	end

	controls.SwipeDistance = UI.CreateSlider(swipeSupport,
		"Movimento para trocar", 18, 180, Config.MobileFriendlyMoveThreshold, " px",
		function(value)
			if not TargetSwipe.IsEnabled() then
				if controls.SwipeDistance then
					controls.SwipeDistance:SetValue(Config.MobileFriendlyMoveThreshold, false)
				end
				return
			end
			Config.MobileFriendlyMoveThreshold = math.floor(value + 0.5)
			TargetSwipe.Cancel("Movimento do gesto alterado")
		end,
		{Id = "mobile.swipe.distance", Description = "Maior precisa de um deslize mais longo."})
	controls.SwipeInvert = UI.CreateToggle(swipeSupport, "Inverter gesto",
		"Troca o sentido: puxar para a direita escolhe um alvo à esquerda.",
		{Id = "mobile.swipe.invert"})
	controls.SwipeInvert.Card.MouseButton1Click:Connect(function()
		if not TargetSwipe.IsEnabled() then return end
		Config.MobileFriendlyInvertGesture = not Config.MobileFriendlyInvertGesture
		TargetSwipe.Cancel("Sentido do gesto alterado")
		controls.Refresh()
	end)
	for _, control in ipairs({controls.SwipeDistance, controls.SwipeInvert}) do
		control.Card.Visible = mobileFriendlyVisible
		if control.Record then control.Record.Card.Visible = mobileFriendlyVisible end
	end

	swipeShell.Visible = mobileFriendlyVisible

	local appearanceStack = UI.SettingsGroup(menuCategory, "Cor e formato", "Escolha como o menu aparece na tela.", "Engine:Appearance")
	local interfaceStack = UI.SettingsGroup(menuCategory, "Tamanho e leitura", "Ajuste o painel e o espaço dos controles.", "Engine:Stack2")

	controls.MenuSizeMode = UI.CreateCycle(
		interfaceStack,
		"Tamanho pronto",
		"Escolha um tamanho ou use a barra abaixo para ajustar do seu jeito."
	)

	controls.MenuScale = UI.CreateSlider(
		interfaceStack,
		"Tamanho do menu",
		math.floor(MENU_SCALE_MIN * 100 + 0.5),
		math.floor(MENU_SCALE_MAX * 100 + 0.5),
		math.floor(Config.MenuScale * 100 + 0.5),
		"%",
		function(value)
			Config.MenuSizeMode = "CUSTOM"
			Config.MenuCustomWidth = 0
			Config.MenuCustomHeight = 0
			controls.MenuSizeMode.Value.Text = "PERSONALIZADO"
			Config.MenuScale = math.clamp(
				value / 100,
				MENU_SCALE_MIN,
				MENU_SCALE_MAX
			)
			if State.UI.ApplyMenuScale then
				-- During a drag, direct frame-by-frame resizing is smoother and
				-- cheaper than cancelling and recreating a tween every frame.
				State.UI.ApplyMenuScale(
					Config.MenuScale,
					UI.ActiveSlider ~= nil
				)
			end
		end
	)

	controls.ControlScale = UI.CreateSlider(
		interfaceStack,
		"Tamanho das opções",
		math.floor(CONTROL_SCALE_MIN * 100 + 0.5),
		math.floor(CONTROL_SCALE_MAX * 100 + 0.5),
		math.floor(Config.ControlScale * 100 + 0.5),
		"%",
		function(value)
			UI.ApplyControlScale(value / 100)
		end
	)

	controls.Theme = UI.CreateCycle(
		appearanceStack,
		"Cor do menu",
		"Troca a cor dos destaques, das seleções e do ESP."
	)

	controls.LayoutStyle = UI.CreateCycle(
		appearanceStack,
		"Formato do menu",
		"Escolhe quanto espaço vai para o menu e para a lista de jogadores."
	)

	UI.OrganizerContainerCounts[page] = 2
	local diagnosticContent, diagnosticGroup = UI.CreateExpandableGroup(
		orderCategory,
		"Informações de teste",
		"Detalhes para investigar um problema na mira.",
		false
	)
	diagnosticGroup.Shell.LayoutOrder = 20
	controls.Debug = UI.CreateToggle(
		diagnosticContent,
		"Mostrar informações de teste",
		"Exibe na tela o que a mira está encontrando."
	)

	controls.ThemeOrder = {
		"RED",
		"BLUE",
		"PURPLE",
		"GREEN",
		"ORANGE",
		"CYAN",
	}
	controls.MenuSizeOrder = {
		"COMPACT",
		"BALANCED",
		"LARGE",
	}
	controls.MenuSizeValues = {
		COMPACT = 0.80,
		BALANCED = 0.92,
		LARGE = 1.08,
	}
	controls.MenuSizeLabels = {
		COMPACT = "COMPACTO",
		BALANCED = "EQUILIBRADO",
		LARGE = "AMPLO",
		CUSTOM = "PERSONALIZADO",
	}
	controls.LayoutOrder = {
		"BALANCED",
		"FOCUS",
		"TARGETS",
		"CLEAN",
	}

	local organizerStack, organizerShell = UI.SettingsGroup(orderCategory, "Organize do seu jeito", "Ative a edição e arraste pelas alças.", "Engine:Stack4")
	organizerShell.LayoutOrder = 1

	controls.LayoutEditor = UI.CreateToggle(
		organizerStack,
		"Editar ordem das opções",
		"Mostra uma alça para arrastar cada opção.",
		{
			Organizable = false,
			Help = "Arraste pela alça que aparece em cada opção. Para mudar de aba, segure a opção sobre o nome da aba e solte depois que ela abrir.",
		}
	)
	controls.ResetControlLayout = UI.CreateCycle(
		organizerStack,
		"Restaurar ordem original",
		"Coloca as opções no lugar inicial sem mudar seus valores.",
		{Organizable = false}
	)
	controls.ResetControlLayout.Value.Text = "RESTAURAR"

	local saveGroup = UI.SettingsGroup(filesCategory, "Salvar seus ajustes", "Guarde uma configuração para usar depois.")
	local configPanel = Util.New("Frame", {
		Name = "AAP_SaveConfiguration", Size = UDim2.new(1, 0, 0, 94),
		BackgroundColor3 = Theme.Card, BackgroundTransparency = .10, BorderSizePixel = 0,
	}, saveGroup)
	Util.Corner(configPanel, 12)
	Util.Stroke(configPanel, Theme.BorderSoft, .6, 1)
	UI.SettingsText(configPanel, "Nome da configuração", UDim2.fromOffset(12, 10), UDim2.new(1, -24, 0, 18), 9, Theme.Text, true)
	controls.ConfigName = Util.New("TextBox", {
		Position = UDim2.fromOffset(12, 38), Size = UDim2.new(1, -114, 0, 36),
		BackgroundColor3 = Theme.Surface3, BackgroundTransparency = .1, BorderSizePixel = 0,
		PlaceholderText = "Ex.: Sniper principal", PlaceholderColor3 = Theme.Sub,
		Text = "", TextColor3 = Theme.Text, Font = Enum.Font.Gotham, TextSize = 9,
		TextXAlignment = Enum.TextXAlignment.Left, ClearTextOnFocus = false, MultiLine = false,
	}, configPanel)
	Util.Corner(controls.ConfigName, 10)
	Util.New("UIPadding", {PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10)}, controls.ConfigName)
	controls.SaveConfig = Util.New("TextButton", {
		Position = UDim2.new(1, -94, 0, 38), Size = UDim2.fromOffset(82, 36),
		BackgroundColor3 = Theme.AccentSoft, BorderSizePixel = 0, Text = "Salvar",
		TextColor3 = Theme.Text, Font = Enum.Font.GothamBold, TextSize = 10, AutoButtonColor = false,
	}, configPanel)
	Util.Corner(controls.SaveConfig, 10)
	Util.Stroke(controls.SaveConfig, Theme.Accent, .35, 1)
	UI.TouchFeedback(controls.SaveConfig)
	local listGroup = UI.SettingsGroup(filesCategory, "Suas configurações", nil)
	controls.ConfigStatus = UI.SettingsText(listGroup, "", UDim2.new(), UDim2.new(1, 0, 0, 32), 8, Theme.Sub)
	controls.ConfigStatus.TextWrapped = true
	controls.ConfigList = Util.New("Frame", {
		Name = "AAP_SavedConfigurations", Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1,
	}, listGroup)
	Util.New("UIListLayout", {Padding = UDim.new(0, 7), SortOrder = Enum.SortOrder.LayoutOrder}, controls.ConfigList)
	controls.ConfigEmpty = UI.SettingsText(controls.ConfigList, "Você ainda não salvou nenhuma configuração.", UDim2.new(), UDim2.new(1, 0, 0, 56), 9, Theme.Sub)
	controls.ConfigEmpty.TextWrapped = true
	controls.ConfigRows = {}
	local resetContent, resetGroup = UI.CreateExpandableGroup(filesCategory, "Restaurar configurações", "Volta aos valores iniciais do script.", false)
	resetGroup.Shell.LayoutOrder = 30
	controls.ResetGroup = resetGroup
	controls.ResetConfig = Util.New("TextButton", {
		Size = UDim2.new(1, 0, 0, 42), BackgroundColor3 = Theme.Card, BackgroundTransparency = .1,
		BorderSizePixel = 0, Text = "Restaurar tudo", TextColor3 = Theme.Danger,
		Font = Enum.Font.GothamMedium, TextSize = 9, AutoButtonColor = false,
	}, resetContent)
	Util.Corner(controls.ResetConfig, 10)
	Util.Stroke(controls.ResetConfig, Theme.Danger, .6, 1)
	UI.TouchFeedback(controls.ResetConfig)
	local function layoutSavedRow(entry)
		local narrow = entry.Card.AbsoluteSize.X < 320
		entry.Card.Size = UDim2.new(1, 0, 0, narrow and 86 or 62)
		entry.Title.Position = UDim2.fromOffset(12, narrow and 10 or 12)
		entry.Title.Size = UDim2.new(1, narrow and -24 or -180, 0, 18)
		entry.Detail.Position = UDim2.fromOffset(12, 34)
		entry.Detail.Size = UDim2.new(1, -180, 0, 14)
		entry.Detail.Visible = not narrow
		entry.Load.Position = narrow and UDim2.fromOffset(12, 42) or UDim2.new(1, -158, 0, 15)
		entry.Load.Size = narrow and UDim2.new(.5, -16, 0, 32) or UDim2.fromOffset(76, 32)
		entry.Delete.Position = narrow and UDim2.new(.5, 4, 0, 42) or UDim2.new(1, -74, 0, 15)
		entry.Delete.Size = narrow and UDim2.new(.5, -16, 0, 32) or UDim2.fromOffset(62, 32)
	end
	function controls.RefreshConfigurations()
		if not Runtime.Alive or not controls.ConfigList.Parent then return end
		local names, present = Persistence.List(), {}
		view.SavedCount = #names
		controls.ConfigStatus.Text = tostring(#names) .. (#names == 1 and " configuração salva" or " configurações salvas")
			.. (Persistence.HasDiskStorage() and " neste dispositivo." or " nesta sessão.")
		controls.ConfigEmpty.Visible = #names == 0
		for index, name in ipairs(names) do
			present[name] = true
			local entry = controls.ConfigRows[name]
			if not entry then
				entry = {}
				entry.Card = Util.New("Frame", {
					Size = UDim2.new(1, 0, 0, 62), BackgroundColor3 = Theme.Card, BackgroundTransparency = .10,
					BorderSizePixel = 0, ClipsDescendants = true,
				}, controls.ConfigList)
				Util.Corner(entry.Card, 12)
				Util.Stroke(entry.Card, Theme.BorderSoft, .7, 1)
				entry.Title = UI.SettingsText(entry.Card, name, UDim2.new(), UDim2.new(), 10, Theme.Text, true)
				entry.Detail = UI.SettingsText(entry.Card, "Pronta para carregar", UDim2.new(), UDim2.new(), 8, Theme.Sub)
				for _, key in ipairs({"Load", "Delete"}) do
					entry[key] = Util.New("TextButton", {
						BackgroundColor3 = key == "Load" and Theme.AccentSoft or Theme.Surface3, BorderSizePixel = 0,
						Text = key == "Load" and "Carregar" or "Excluir", TextColor3 = key == "Load" and Theme.Text or Theme.Sub,
						Font = Enum.Font.GothamMedium, TextSize = 8, AutoButtonColor = false,
					}, entry.Card)
					Util.Corner(entry[key], 10)
					Util.FitText(entry[key], 7, 9)
					UI.TouchFeedback(entry[key])
				end
				entry.Load.Activated:Connect(function()
					if State.UI.LayoutEditMode then return end
					local ok, result = Persistence.Load(name)
					if ok then
						controls.ConfigName.Text = result
						UI.ApplyConfigurationState("Configuração carregada: " .. result, false)
					else UI.Toast(result) end
				end)
				entry.Delete.Activated:Connect(function()
					if State.UI.LayoutEditMode then return end
					local now = os.clock()
					if not entry.ArmedUntil or now > entry.ArmedUntil then
						entry.ArmedUntil = now + 3
						entry.Delete.Text = "Confirmar"
						entry.Delete.TextColor3 = Theme.Danger
						UI.Toast("Toque em Confirmar para excluir " .. name .. ".")
						task.delay(3.1, function()
							if Runtime.Alive and entry.Card.Parent and entry.ArmedUntil and os.clock() > entry.ArmedUntil then
								entry.ArmedUntil = nil; entry.Delete.Text = "Excluir"; entry.Delete.TextColor3 = Theme.Sub
							end
						end)
						return
					end
					entry.ArmedUntil = nil
					local ok, result = Persistence.Delete(name)
					entry.Delete.Text = "Excluir"; entry.Delete.TextColor3 = Theme.Sub
					UI.Toast(ok and ("Configuração excluída: " .. result) or result)
					controls.RefreshConfigurations()
				end)
				entry.Card:GetPropertyChangedSignal("AbsoluteSize"):Connect(function() layoutSavedRow(entry) end)
				controls.ConfigRows[name] = entry
			end
			entry.Card.LayoutOrder = index
			layoutSavedRow(entry)
		end
		for name, entry in pairs(controls.ConfigRows) do
			if not present[name] then entry.Card:Destroy(); controls.ConfigRows[name] = nil end
		end
		view.Refresh()
	end
	controls.SaveConfig.Activated:Connect(function()
		if State.UI.LayoutEditMode then return end
		local name = Persistence.SafeName(controls.ConfigName.Text)
		local overwrite = name ~= nil and controls.OverwriteName == name and os.clock() <= (controls.OverwriteArmedUntil or 0)
		local ok, result, code = Persistence.Save(controls.ConfigName.Text, overwrite)
		controls.OverwriteName, controls.OverwriteArmedUntil = nil, 0
		controls.SaveConfig.Text = "Salvar"
		if code == "EXISTS" then
			controls.OverwriteName, controls.OverwriteArmedUntil = name, os.clock() + 3
			controls.SaveConfig.Text = "Substituir"
			task.delay(3.1, function()
				if Runtime.Alive and controls.SaveConfig.Parent and os.clock() > controls.OverwriteArmedUntil then controls.SaveConfig.Text = "Salvar" end
			end)
		end
		if ok then
			controls.ConfigName.Text = result
			controls.ConfigName:ReleaseFocus(false)
			UI.Toast("Configuração salva: " .. result)
			controls.RefreshConfigurations()
		else UI.Toast(result) end
	end)
	controls.ConfigName:GetPropertyChangedSignal("Text"):Connect(function()
		if Persistence.SafeName(controls.ConfigName.Text) ~= controls.OverwriteName then
			controls.OverwriteName, controls.OverwriteArmedUntil = nil, 0
			controls.SaveConfig.Text = "Salvar"
		end
	end)
	controls.ResetArmedUntil = 0
	controls.ResetConfig.Activated:Connect(function()
		if State.UI.LayoutEditMode then return end
		local now = os.clock()
		if now > controls.ResetArmedUntil then
			controls.ResetArmedUntil = now + 3
			controls.ResetConfig.Text = "Confirmar restauração"
			UI.Toast("Toque novamente para restaurar tudo.")
			task.delay(3.1, function()
				if Runtime.Alive and controls.ResetConfig.Parent and os.clock() > controls.ResetArmedUntil then controls.ResetConfig.Text = "Restaurar tudo" end
			end)
			return
		end
		controls.ResetArmedUntil = 0
		Persistence.Reset()
		for player in pairs(State.ManualAllies) do State.ManualAllies[player] = nil end
		controls.ConfigName.Text = ""
		controls.ResetConfig.Text = "Restaurar tudo"
		UI.ApplyConfigurationState("Todas as opções foram restauradas", true)
	end)
	local function layoutSaveForm()
		local narrow = configPanel.AbsoluteSize.X < 280
		configPanel.Size = UDim2.new(1, 0, 0, narrow and 126 or 94)
		controls.ConfigName.Size = UDim2.new(1, narrow and -24 or -114, 0, 36)
		controls.SaveConfig.Position = narrow and UDim2.fromOffset(12, 82) or UDim2.new(1, -94, 0, 38)
		controls.SaveConfig.Size = narrow and UDim2.new(1, -24, 0, 32) or UDim2.fromOffset(82, 36)
	end
	configPanel:GetPropertyChangedSignal("AbsoluteSize"):Connect(layoutSaveForm)
	layoutSaveForm()
	view:AddSetting("FILES", {Card = configPanel}, "guardar salvar configuracao configuração nome", nil, "Salvar configuração")
	view:AddSetting("FILES", {Card = controls.ConfigList}, "carregar excluir arquivos salvos", nil, "Configurações salvas")
	view:AddSetting("FILES", {Card = controls.ResetConfig}, "reset padrão padrao valores originais", function() resetGroup:SetExpanded(true) end, "Restaurar tudo")

	controls.ProfileOrder = {
		"DEFAULT",
		"RIFLE",
		"SMG",
		"SNIPER",
		"PISTOL",
		"SHOTGUN",
		"DMR",
		"LMG",
		"PROJECTILE",
	}

	function controls.Refresh()
		refreshSettingsCategoryButtons()

		UI.SetToggle(
			controls.Distance,
			Config.DistanceCompensation
		)

		UI.SetToggle(
			controls.Debug,
			Config.DebugEnabled
		)

		UI.SetToggle(
			controls.MobileQuick,
			Config.MobileQuickControls
		)

		UI.SetToggle(
			controls.MobileLock,
			Config.MobileQuickLocked
		)
		UI.SetControlAvailable(
			controls.MobileLock,
			Config.MobileQuickControls,
			"Disponível quando Mostrar atalhos na tela estiver ativado."
		)

		UI.SetToggle(controls.MobileFriendly, Config.MobileFriendlySwitch)
		UI.SetToggle(controls.SwipeInvert, Config.MobileFriendlyInvertGesture)
		controls.SwipeDistance:SetValue(Config.MobileFriendlyMoveThreshold, false)
		for _, control in ipairs({controls.SwipeDistance, controls.SwipeInvert}) do
			UI.SetControlAvailable(control, Config.MobileFriendlySwitch,
				"Disponível quando Troca de alvo por gesto estiver ativada.")
		end

		controls.Curve.Value.Text =
			Config.SmoothingCurve == "DYNAMIC"
			and "ADAPTATIVO"
			or "CONSTANTE"

		controls.Profile.Value.Text =
			WeaponProfileLabels[Config.WeaponProfile]
			or Config.WeaponProfile

		controls.Horizontal:SetValue(
			Config.HorizontalStrength,
			false
		)

		controls.Vertical:SetValue(
			Config.VerticalStrength,
			false
		)

		controls.MenuScale:SetValue(
			math.floor(Config.MenuScale * 100 + 0.5),
			false
		)
		controls.ControlScale:SetValue(
			math.floor(Config.ControlScale * 100 + 0.5),
			false
		)
		controls.MenuSizeMode.Value.Text =
			controls.MenuSizeLabels[Config.MenuSizeMode]
			or "PERSONALIZADO"
		local layoutPreset = MENU_LAYOUT_PRESETS[Config.MenuLayoutStyle]
			or MENU_LAYOUT_PRESETS.BALANCED
		controls.LayoutStyle.Value.Text = layoutPreset.Label
		UI.SetToggle(
			controls.LayoutEditor,
			State.UI.LayoutEditMode == true
		)
		controls.ResetControlLayout.Value.Text = "RESTAURAR"

		local themePreset =
			ThemePresets[Config.UITheme]
			or ThemePresets.RED
		controls.Theme.Value.Text = themePreset.Label

		State.UI.DebugOverlay.Visible =
			Config.DebugEnabled
	end

	controls.Distance.Card.MouseButton1Click:
		Connect(function()

			Config.DistanceCompensation =
				not Config.DistanceCompensation

			Aim.MarkAssistantCustomized()
			controls.Refresh()
		end)

	controls.Debug.Card.MouseButton1Click:
		Connect(function()

			Config.DebugEnabled =
				not Config.DebugEnabled

			controls.Refresh()
		end)

	controls.MobileQuick.Card.MouseButton1Click:
		Connect(function()
			UI.SetMobileQuickControlsVisible(
				not Config.MobileQuickControls
			)
		end)

	controls.MobileLock.Card.MouseButton1Click:
		Connect(function()
			if not Config.MobileQuickControls then
				UI.Toast("Ative Mostrar atalhos na tela primeiro.")
				return
			end
			UI.SetMobileQuickLocked(
				not Config.MobileQuickLocked
			)
		end)

	controls.MobileFriendly.Card.MouseButton1Click:
		Connect(function()
			UI.SetMobileFriendlySwitch(
				not Config.MobileFriendlySwitch
			)
		end)

	local themeChoices = {}
	for _, themeName in ipairs(controls.ThemeOrder) do
		themeChoices[#themeChoices + 1] = {
			Value = themeName,
			Label = ThemePresets[themeName].Label,
		}
	end
	UI.BindChoiceMenu(
		controls.Theme,
		"Cor do menu",
		themeChoices,
		function()
			return Config.UITheme
		end,
		function(value)
			Config.UITheme = value
			UI.ApplyTheme(Config.UITheme)
			UI.RefreshAllControls()
			controls.Refresh()
			UI.Toast(
				"Cor do menu: "
				.. (ThemePresets[Config.UITheme].Label or Config.UITheme)
			)
		end
	)

	local menuSizeChoices = {}
	local menuSizeDescriptions = {
		COMPACT = "Ocupa menos espaço na tela.",
		BALANCED = "Tamanho confortável para a maioria dos celulares.",
		LARGE = "Aumenta o menu para facilitar os toques.",
	}
	for _, sizeName in ipairs(controls.MenuSizeOrder) do
		menuSizeChoices[#menuSizeChoices + 1] = {
			Value = sizeName,
			Label = controls.MenuSizeLabels[sizeName],
			Description = menuSizeDescriptions[sizeName],
		}
	end
	UI.BindChoiceMenu(
		controls.MenuSizeMode,
		"Tamanho pronto",
		menuSizeChoices,
		function()
			return Config.MenuSizeMode
		end,
		function(value)
			Config.MenuSizeMode = value
			Config.MenuCustomWidth = 0
			Config.MenuCustomHeight = 0
			Config.MenuScale = controls.MenuSizeValues[value]
			if State.UI.ApplyMenuScale then
				State.UI.ApplyMenuScale(Config.MenuScale, false)
			end
			controls.Refresh()
			UI.Toast(
				"Tamanho do menu: "
				.. controls.MenuSizeLabels[Config.MenuSizeMode]
			)
		end
	)

	local layoutChoices = {}
	for _, layoutName in ipairs(controls.LayoutOrder) do
		layoutChoices[#layoutChoices + 1] = {
			Value = layoutName,
			Label = MENU_LAYOUT_PRESETS[layoutName].Label,
			Description = MENU_LAYOUT_PRESETS[layoutName].Description,
		}
	end
	UI.BindChoiceMenu(
		controls.LayoutStyle,
		"Formato do menu",
		layoutChoices,
		function()
			return Config.MenuLayoutStyle
		end,
		function(value)
			if State.UI.ApplyMenuLayoutStyle then
				State.UI.ApplyMenuLayoutStyle(value)
			else
				Config.MenuLayoutStyle = value
			end
			controls.Refresh()
			UI.Toast(
				"Formato do menu: "
				.. (MENU_LAYOUT_PRESETS[value].Label or value)
			)
		end
	)

	controls.LayoutEditor.Card.MouseButton1Click:Connect(function()
		UI.SetControlOrganizerEnabled(not State.UI.LayoutEditMode)
		UI.Toast(
			State.UI.LayoutEditMode
			and "Organização liberada. Arraste pelas alças."
			or "Nova organização salva."
		)
	end)

	controls.ResetControlLayout.Card.MouseButton1Click:Connect(function()
		UI.ResetControlLayout()
		controls.Refresh()
		UI.Toast("Ordem original restaurada.")
	end)

	UI.BindChoiceMenu(
		controls.Curve,
		"Tipo de movimento",
		{
			{Value = "DYNAMIC", Label = "ADAPTATIVO", Description = "Desacelera ao se aproximar do alvo."},
			{Value = "LINEAR", Label = "CONSTANTE", Description = "Mantém a mesma velocidade de resposta."},
		},
		function()
			return Config.SmoothingCurve
		end,
		function(value)
			Config.SmoothingCurve = value
			Aim.MarkAssistantCustomized()
			controls.Refresh()
		end
	)

	local profileChoices = {}
	for _, profileName in ipairs(controls.ProfileOrder) do
		profileChoices[#profileChoices + 1] = {
			Value = profileName,
			Label = WeaponProfileLabels[profileName] or profileName,
		}
	end
	UI.BindChoiceMenu(
		controls.Profile,
		"Ajuste fino da arma",
		profileChoices,
		function()
			return Config.WeaponProfile
		end,
		function(value)
			Config.WeaponProfile = value
			Config.AimAssistant.Applied = false
			Config.AimAssistant.Customized = false
			State.ActiveQuickPresetKey = nil

			if State.UI.RefreshQuickPresetVisuals then
				State.UI.RefreshQuickPresetVisuals()
			end
			if State.UI.CurrentProfileLabel then
				State.UI.CurrentProfileLabel.Text = "PERSONALIZADO"
			end
			if State.UI.CurrentWeaponLabel then
				State.UI.CurrentWeaponLabel.Text =
					WeaponProfileLabels[Config.WeaponProfile]
					or Config.WeaponProfile
			end
			if State.UI.RefreshAssistantControls then
				State.UI.RefreshAssistantControls()
			end
			controls.Refresh()
		end
	)

	local settingsIndex = {
		{"MENU", "Theme", "cor cores tema visual"},
		{"MENU", "LayoutStyle", "formato layout lista jogadores"},
		{"MENU", "MenuSizeMode", "tamanho compacto equilibrado amplo"},
		{"MENU", "MenuScale", "tamanho escala painel zoom"},
		{"MENU", "ControlScale", "tamanho botoes botões cartões leitura"},
		{"MOBILE", "MobileQuick", "atalhos botões botoes na tela"},
		{"MOBILE", "MobileLock", "travar fixar posição posicao atalhos"},
		{"MOBILE", "MobileFriendly", "troca alvo gesto deslizar mobile"},
		{"MOBILE", "SwipeDistance", "movimento sensibilidade deslize distância distancia"},
		{"MOBILE", "SwipeInvert", "inverter sentido direção direcao gesto"},
		{"ORDER", "LayoutEditor", "editar ordem arrastar organizar opções opcoes"},
		{"ORDER", "ResetControlLayout", "restaurar ordem original"},
		{"ORDER", "Debug", "diagnostico diagnóstico debug teste"},
	}
	for _, entry in ipairs(settingsIndex) do
		local control = controls[entry[2]]
		UI.StyleSettingsControl(control)
		local open = entry[2] == "Debug" and function() diagnosticGroup:SetExpanded(true) end or nil
		view:AddSetting(entry[1], control, entry[3], open)
	end
	controls.Theme.Record.Card.LayoutOrder = 1
	controls.LayoutStyle.Record.Card.LayoutOrder = 2
	controls.MenuSizeMode.Record.Card.LayoutOrder = 1
	controls.MenuScale.Record.Card.LayoutOrder = 2
	controls.ControlScale.Record.Card.LayoutOrder = 3
	controls.MobileQuick.Record.Card.LayoutOrder = 1
	controls.MobileLock.Record.Card.LayoutOrder = 2
	controls.MobileFriendly.Record.Card.LayoutOrder = 1
	controls.SwipeDistance.Record.Card.LayoutOrder = 2
	controls.SwipeInvert.Record.Card.LayoutOrder = 3
	controls.LayoutEditor.Card.LayoutOrder = 1
	controls.ResetControlLayout.Card.LayoutOrder = 2
	State.UI.SettingsControls = controls

	State.UI.RefreshEngineControls = controls.Refresh
	State.UI.RefreshConfigurationControls = controls.RefreshConfigurations
	showSettingsCategory("HOME", false)
	controls.RefreshConfigurations()
	controls.Refresh()

	return page
end

function Pages.BuildFilters()
	local page = UI.CreatePage("Filters")
	local controls = {}

	UI.Section(
		page,
		"QUEM A MIRA PODE ESCOLHER",
		"A mira ignora qualquer jogador que você marcar como protegido."
	)

	local targetList = UI.Stack(page)
	controls.FocusEveryone = UI.CreateToggle(
		targetList,
		"Usar qualquer jogador disponível",
		"Ativado procura qualquer jogador sem proteção. Desativado usa apenas quem você escolheu."
	)

	UI.Section(
		page,
		"COMO PROTEGER UM JOGADOR",
		"Abra Jogadores e toque em Proteger. A mira vai ignorar essa pessoa."
	)

	local guide = Util.New("Frame", {
		Size = UDim2.new(1, 0, 0, 132),
		BackgroundColor3 = Theme.Card,
		BackgroundTransparency = 0.06,
		BorderSizePixel = 0,
		ClipsDescendants = true,
	}, page)
	Util.Corner(guide, 15)
	Util.Stroke(guide, Theme.BorderInner, 0.58, 1)
	Util.Sheen(guide, 0.07)

	Util.New("TextLabel", {
		Position = UDim2.fromOffset(13, 12),
		Size = UDim2.new(1, -26, 0, 18),
		BackgroundTransparency = 1,
		Text = "PROTEÇÃO MANUAL",
		TextColor3 = Theme.Text,
		Font = Enum.Font.GothamBold,
		TextSize = 8,
		TextXAlignment = Enum.TextXAlignment.Left,
	}, guide)

	Util.New("TextLabel", {
		Position = UDim2.fromOffset(13, 35),
		Size = UDim2.new(1, -26, 0, 38),
		BackgroundTransparency = 1,
		Text = "Use quando quiser garantir que uma pessoa nunca seja escolhida pela mira.",
		TextColor3 = Theme.Sub,
		Font = Enum.Font.Gotham,
		TextSize = 7,
		TextWrapped = true,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Top,
	}, guide)

	controls.ManualTeamStatus = Util.New("TextLabel", {
		Position = UDim2.fromOffset(13, 78),
		Size = UDim2.new(0.48, -18, 0, 38),
		BackgroundColor3 = RelationColors.ALLY:Lerp(Theme.Card, 0.72),
		BackgroundTransparency = 0.10,
		BorderSizePixel = 0,
		Text = "0 JOGADORES PROTEGIDOS",
		TextColor3 = RelationColors.ALLY,
		Font = Enum.Font.GothamBold,
		TextSize = 7,
	}, guide)
	Util.Corner(controls.ManualTeamStatus, 999)
	Util.Stroke(controls.ManualTeamStatus, RelationColors.ALLY, 0.48, 1)
	Util.FitText(controls.ManualTeamStatus, 5, 8)

	controls.OpenPlayers = Util.New("TextButton", {
		Position = UDim2.new(0.48, 4, 0, 78),
		Size = UDim2.new(0.52, -17, 0, 38),
		BackgroundColor3 = Theme.CardActive,
		BackgroundTransparency = 0.02,
		BorderSizePixel = 0,
		Text = "ABRIR JOGADORES",
		TextColor3 = Theme.Text,
		Font = Enum.Font.GothamBold,
		TextSize = 7,
		AutoButtonColor = false,
	}, guide)
	Util.Corner(controls.OpenPlayers, 999)
	Util.Stroke(controls.OpenPlayers, Theme.Accent2, 0.30, 1)
	UI.TouchFeedback(controls.OpenPlayers)

	function controls.Refresh()
		UI.SetToggle(
			controls.FocusEveryone,
			Config.AimMode == "AUTO"
		)

		local count = 0
		for player in pairs(State.ManualAllies) do
			if player.Parent == S.Players then
				count += 1
			end
		end

		controls.ManualTeamStatus.Text =
			tostring(count)
				.. (count == 1
					and " JOGADOR PROTEGIDO"
					or " JOGADORES PROTEGIDOS")
	end

	controls.FocusEveryone.Card.MouseButton1Click:Connect(function()
		Config.AimMode =
			Config.AimMode == "AUTO"
			and "SELECTED"
			or "AUTO"

		Aim.ClearCurrentTarget("Modo de alvo alterado")
		controls.Refresh()

		if State.UI.RefreshAimControls then
			State.UI.RefreshAimControls()
		end

		UI.Toast(
			Config.AimMode == "AUTO"
			and "A mira agora procura qualquer jogador"
			or "A mira agora usa somente o jogador escolhido"
		)
	end)

	controls.OpenPlayers.MouseButton1Click:Connect(function()
		if State.UI.Pages and State.UI.Pages.Players then
			UI.ShowPage(State.UI.Pages.Players)
		end
	end)

	State.UI.RefreshFilters = function()
		controls.Refresh()
		UI.RefreshTeamSidebar()
	end

	State.UI.RefreshTeams = function()
		UI.RefreshTeamSidebar()
	end
	controls.Refresh()
	UI.RefreshTeamSidebar()

	return page
end

function Pages.BuildESP()
	local page =
		UI.CreatePage("ESP")

	local controls = {}

	UI.Section(
		page,
		"ESP",
		"Mostra informações dos jogadores durante a partida."
	)

	local list =
		UI.Stack(page)

	controls.Enabled =
		UI.CreateToggle(
			list,
			"Ativar ESP",
			"Mostra ou esconde todas as informações visuais dos jogadores."
		)

	local details = UI.CreateExpandableGroup(
		page,
		"O QUE MOSTRAR",
		"Estas opções aparecem no jogo quando Ativar ESP estiver ligado.",
		false
	)

	controls.Global =
		UI.CreateToggle(
			details,
			"Mostrar todos",
			"Exibe o ESP em todos os jogadores, inclusive os protegidos.",
			{
				Help = "Esta opção vale apenas para o ESP. Ela não permite que a mira escolha jogadores protegidos.",
			}
		)

	controls.Enemies =
		UI.CreateToggle(
			details,
			"Mostrar jogadores disponíveis",
			"Com Mostrar todos desligado, exibe quem pode ser escolhido pela mira."
		)

	controls.Allies =
		UI.CreateToggle(
			details,
			"Mostrar jogadores protegidos",
			"Com Mostrar todos desligado, exibe quem você marcou como protegido."
		)

	controls.TeamColors =
		UI.CreateToggle(
			details,
			"Usar cores das equipes",
			"Usa a cor informada pelo jogo no lugar da cor do menu."
		)

	controls.Selected =
		UI.CreateToggle(
			details,
			"Destacar jogador escolhido",
			"Dá um destaque extra ao jogador marcado com FOCAR.",
			{Id = "ESP:destacar_alvo_atual"}
		)

	controls.Labels =
		UI.CreateToggle(
			details,
			"Mostrar nome e distância",
			"Exibe o nome, a equipe e a distância acima do jogador."
		)

	function controls.Refresh()
		UI.SetToggle(
			controls.Enabled,
			Config.ESPEnabled
		)

		UI.SetToggle(
			controls.Global,
			Config.GlobalESP
		)

		UI.SetToggle(
			controls.Enemies,
			Config.ESPEnemies
		)

		UI.SetToggle(
			controls.Allies,
			Config.ESPAllies
		)

		UI.SetToggle(
			controls.TeamColors,
			Config.ESPUseTeamColors
		)

		UI.SetToggle(
			controls.Selected,
			Config.SelectedESP
		)

		UI.SetToggle(
			controls.Labels,
			Config.ESPLabels
		)
	end

	local mapping = {
		{controls.Enabled, "ESPEnabled"},
		{controls.Global, "GlobalESP"},
		{controls.Enemies, "ESPEnemies"},
		{controls.Allies, "ESPAllies"},
		{controls.TeamColors, "ESPUseTeamColors"},
		{controls.Selected, "SelectedESP"},
		{controls.Labels, "ESPLabels"},
	}

	for _, item in ipairs(mapping) do
		local control = item[1]
		local key = item[2]

		control.Card.MouseButton1Click:
			Connect(function()
				Config[key] =
					not Config[key]

				controls.Refresh()
				if State.UI.RefreshAimControls then
					State.UI.RefreshAimControls()
				end
				ESP.RefreshAll()
			end)
	end

	State.UI.RefreshESPControls = controls.Refresh
	controls.Refresh()

	return page
end

function UI.TogglePlayerFocus(player)
	if State.UI.LayoutEditMode or not player or player.Parent ~= S.Players then return false end
	if not State.SelectedPlayers[player] then
		return UI.SelectExclusivePlayer(player, "Jogador escolhido na aba JOGADORES")
	end
	State.SelectedPlayers[player] = nil
	if Config.AimMode == "SELECTED" then Config.AimMode = "AUTO" end
	if State.CurrentTarget == player then Aim.ClearCurrentTarget("Jogador desmarcado") end
	ESP.SafeRefresh(player)
	if State.UI.RefreshPlayers then State.UI.RefreshPlayers() end
	if State.UI.RefreshAimControls then State.UI.RefreshAimControls() end
	if State.UI.RefreshFilters then State.UI.RefreshFilters() end
	UI.Toast(player.DisplayName .. " saiu do foco.")
	return true
end

function UI.LayoutPlayerEntry(entry, width)
	local narrow = width < 360
	entry.Card.Size = UDim2.new(1, 0, 0, narrow and 104 or 74)
	entry.Avatar.Position = UDim2.fromOffset(10, narrow and 10 or 17)
	local textRight = narrow and -70 or -230
	entry.Name.Size = UDim2.new(1, textRight, 0, 17)
	entry.Username.Size = UDim2.new(1, textRight, 0, 14)
	entry.Detail.Size = UDim2.new(1, textRight, 0, 14)
	if narrow then
		entry.Focus.Position = UDim2.fromOffset(10, 65)
		entry.Focus.Size = UDim2.new(0.5, -14, 0, 30)
		entry.Protect.Position = UDim2.new(0.5, 4, 0, 65)
		entry.Protect.Size = UDim2.new(0.5, -14, 0, 30)
	else
		entry.Focus.Position = UDim2.new(1, -160, 0, 21)
		entry.Focus.Size = UDim2.fromOffset(68, 32)
		entry.Protect.Position = UDim2.new(1, -84, 0, 21)
		entry.Protect.Size = UDim2.fromOffset(74, 32)
	end
end

function Pages.BuildPlayers()
	local page = UI.CreatePage("Players")
	page:SetAttribute("AAPHideScrollCue", true)
	page.Position = UDim2.fromOffset(3, 79)
	page.Size = UDim2.new(1, -6, 1, -82)
	page.ScrollBarThickness = 3
	local controls = {Entries = {}, Filter = "ALL", Query = "", SearchGeneration = 0}
	local toolbar = Util.New("Frame", {
		Name = "AAP_PlayerToolbar", Position = UDim2.fromOffset(7, 5),
		Size = UDim2.new(1, -22, 0, 68), BackgroundTransparency = 1,
		BorderSizePixel = 0, Visible = page.Visible,
	}, page.Parent)
	controls.Toolbar = toolbar
	local searchCard = Util.New("Frame", {
		Name = "AAP_PlayerSearch", Size = UDim2.new(1, -144, 0, 30),
		BackgroundColor3 = Theme.Surface3, BackgroundTransparency = 0.25, BorderSizePixel = 0,
	}, toolbar)
	Util.Corner(searchCard, 10)
	Util.Stroke(searchCard, Theme.BorderSoft, 0.65, 1)
	controls.Search = Util.New("TextBox", {
		Position = UDim2.fromOffset(10, 0), Size = UDim2.new(1, -40, 1, 0),
		BackgroundTransparency = 1, Text = "", PlaceholderText = "Buscar nome ou @usuário",
		PlaceholderColor3 = Theme.Sub, TextColor3 = Theme.Text,
		Font = Enum.Font.Gotham, TextSize = 9, ClearTextOnFocus = false,
		MultiLine = false, TextXAlignment = Enum.TextXAlignment.Left,
	}, searchCard)
	controls.Clear = Util.New("TextButton", {
		AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, 0, 0, 0),
		Size = UDim2.fromOffset(30, 30), BackgroundTransparency = 1, Text = "×",
		TextColor3 = Theme.Sub, Font = Enum.Font.Gotham, TextSize = 14,
		AutoButtonColor = false, Visible = false,
	}, searchCard)
	controls.TapSelect = Util.New("TextButton", {
		Name = "AAP_PlayerTapSelect", Position = UDim2.new(1, -136, 0, 0),
		Size = UDim2.fromOffset(104, 30), BackgroundColor3 = Theme.Card,
		BackgroundTransparency = 0.15, BorderSizePixel = 0, Text = "", AutoButtonColor = false,
	}, toolbar)
	Util.Corner(controls.TapSelect, 10)
	Util.Stroke(controls.TapSelect, Theme.BorderSoft, 0.65, 1)
	Util.FitText(Util.New("TextLabel", {
		Position = UDim2.fromOffset(7, 0), Size = UDim2.new(1, -42, 1, 0),
		BackgroundTransparency = 1, Text = "Toque no jogo", TextColor3 = Theme.Text,
		Font = Enum.Font.GothamMedium, TextSize = 8, TextXAlignment = Enum.TextXAlignment.Left,
	}, controls.TapSelect), 7, 8)
	controls.TapSwitch = Util.New("Frame", {
		AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -7, 0.5, 0),
		Size = UDim2.fromOffset(26, 16), BackgroundColor3 = Theme.Chip, BorderSizePixel = 0,
	}, controls.TapSelect)
	Util.Corner(controls.TapSwitch, 999)
	controls.TapKnob = Util.New("Frame", {
		Position = UDim2.fromOffset(3, 3), Size = UDim2.fromOffset(10, 10),
		BackgroundColor3 = Theme.Muted, BorderSizePixel = 0,
	}, controls.TapSwitch)
	Util.Corner(controls.TapKnob, 999)
	UI.TouchFeedback(controls.TapSelect)
	controls.Help = UI.CreateHelpButton(toolbar, "Escolher jogadores",
		"Focar escolhe essa pessoa e ativa a mira. Soltar volta à busca normal. Proteger impede que ela seja alvo.\n\nToque no jogo permite escolher um personagem tocando nele durante a partida. Arrastar a câmera não conta.\n\nA busca e os filtros organizam só esta lista; eles não mudam as regras da mira.",
		UDim2.new(1, 0, 0, 1))
	local filters = Util.New("Frame", {
		Name = "AAP_PlayerFilters", Position = UDim2.fromOffset(0, 39),
		Size = UDim2.new(1, 0, 0, 28), BackgroundColor3 = Theme.Surface2,
		BackgroundTransparency = 0.1, BorderSizePixel = 0,
	}, toolbar)
	Util.Corner(filters, 10)
	controls.Filters = {}
	local filterData = {{"ALL", "Todos"}, {"FOCUSED", "Em foco"}, {"PROTECTED", "Protegidos"}}
	for index, data in ipairs(filterData) do
		local button = Util.New("TextButton", {
			Position = UDim2.new((index - 1) / 3, 2, 0, 2),
			Size = UDim2.new(1 / 3, -4, 1, -4), BackgroundColor3 = Theme.Surface3,
			BorderSizePixel = 0, Text = data[2], TextColor3 = Theme.Sub,
			Font = Enum.Font.GothamMedium, TextSize = 8, AutoButtonColor = false,
		}, filters)
		Util.Corner(button, 8)
		Util.FitText(button, 7, 9)
		controls.Filters[data[1]] = button
		UI.TouchFeedback(button)
		button.Activated:Connect(function()
			if State.UI.LayoutEditMode then return end
			controls.Filter = data[1]
			page.CanvasPosition = Vector2.zero
			controls.Refresh()
		end)
	end
	controls.Container = Util.New("Frame", {
		Name = "AAP_PlayerList", Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, LayoutOrder = 1,
	}, page)
	Util.New("UIListLayout", {
		Padding = UDim.new(0, 7), SortOrder = Enum.SortOrder.LayoutOrder,
	}, controls.Container)
	controls.Empty = Util.New("Frame", {
		Size = UDim2.new(1, 0, 0, 92), BackgroundColor3 = Theme.Card,
		BackgroundTransparency = 0.45, BorderSizePixel = 0, LayoutOrder = 2, Visible = false,
	}, page)
	Util.Corner(controls.Empty, 12)
	controls.EmptyTitle = Util.FitText(Util.New("TextLabel", {
		Position = UDim2.fromOffset(12, 16), Size = UDim2.new(1, -24, 0, 20),
		BackgroundTransparency = 1, Text = "", TextColor3 = Theme.Text,
		Font = Enum.Font.GothamMedium, TextSize = 10,
	}, controls.Empty), 8, 11)
	controls.EmptyHint = Util.FitText(Util.New("TextLabel", {
		Position = UDim2.fromOffset(12, 42), Size = UDim2.new(1, -24, 0, 30),
		BackgroundTransparency = 1, Text = "", TextColor3 = Theme.Sub, TextWrapped = true,
		Font = Enum.Font.Gotham, TextSize = 8,
	}, controls.Empty), 7, 9)
	local function createEntry(player)
		local entry = {}
		entry.Card = Util.New("Frame", {
			Name = "Player_" .. tostring(player.UserId), Size = UDim2.new(1, 0, 0, 74),
			BackgroundColor3 = Theme.Card, BackgroundTransparency = 0.12,
			BorderSizePixel = 0, ClipsDescendants = true,
		}, controls.Container)
		Util.Corner(entry.Card, 12)
		entry.Stroke = Util.Stroke(entry.Card, Theme.BorderSoft, 0.75, 1)
		entry.Avatar = Util.New("ImageLabel", {
			Size = UDim2.fromOffset(40, 40), BackgroundColor3 = Theme.Surface3,
			BorderSizePixel = 0, Image = "",
		}, entry.Card)
		Util.Corner(entry.Avatar, 10)
		entry.Name = Util.New("TextLabel", {
			Position = UDim2.fromOffset(60, 10), BackgroundTransparency = 1,
			Text = player.DisplayName, TextColor3 = Theme.Text, TextTruncate = Enum.TextTruncate.AtEnd,
			Font = Enum.Font.GothamBold, TextSize = 10, TextXAlignment = Enum.TextXAlignment.Left,
		}, entry.Card)
		entry.Username = Util.New("TextLabel", {
			Position = UDim2.fromOffset(60, 29), BackgroundTransparency = 1,
			Text = "@" .. player.Name, TextColor3 = Theme.Sub, TextTruncate = Enum.TextTruncate.AtEnd,
			Font = Enum.Font.Gotham, TextSize = 8, TextXAlignment = Enum.TextXAlignment.Left,
		}, entry.Card)
		entry.Detail = Util.New("TextLabel", {
			Position = UDim2.fromOffset(60, 46), BackgroundTransparency = 1, Text = "",
			TextColor3 = Theme.Sub, TextTruncate = Enum.TextTruncate.AtEnd,
			Font = Enum.Font.GothamMedium, TextSize = 7, TextXAlignment = Enum.TextXAlignment.Left,
		}, entry.Card)
		for _, key in ipairs({"Focus", "Protect"}) do
			entry[key] = Util.New("TextButton", {
				BackgroundColor3 = Theme.Surface3, BackgroundTransparency = 0.05,
				BorderSizePixel = 0, Text = "", TextColor3 = Theme.Text,
				Font = Enum.Font.GothamMedium, TextSize = 8, AutoButtonColor = false,
			}, entry.Card)
			Util.Corner(entry[key], 9)
			Util.FitText(entry[key], 7, 9)
			UI.TouchFeedback(entry[key])
		end
		entry.Focus.Activated:Connect(function()
			if State.ManualAllies[player] or State.UI.LayoutEditMode then return end
			UI.TogglePlayerFocus(player)
		end)
		entry.Protect.Activated:Connect(function()
			if State.UI.LayoutEditMode then return end
			UI.ToggleManualAlly(player)
		end)
		UI.LoadPlayerThumbnail(entry.Avatar, player)
		return entry
	end
	function controls.Refresh()
		if not Runtime.Alive or not page.Parent then return end
		local players, present = {}, {}
		local counts = {ALL = 0, FOCUSED = 0, PROTECTED = 0}
		for _, player in ipairs(S.Players:GetPlayers()) do
			if player ~= S.LocalPlayer then
				players[#players + 1] = player
				present[player] = true
				counts.ALL += 1
				if State.SelectedPlayers[player] then counts.FOCUSED += 1 end
				if State.ManualAllies[player] then counts.PROTECTED += 1 end
			end
		end
		table.sort(players, function(a, b)
			local aName, bName = string.lower(a.DisplayName), string.lower(b.DisplayName)
			if aName == bName then return a.UserId < b.UserId end
			return aName < bName
		end)
		for player, entry in pairs(controls.Entries) do
			if not present[player] then entry.Card:Destroy(); controls.Entries[player] = nil end
		end
		local width = controls.Container.AbsoluteSize.X
		if width <= 0 then width = math.max(page.AbsoluteSize.X - 19, 1) end
		local shown = 0
		for index, player in ipairs(players) do
			local entry = controls.Entries[player]
			if not entry then entry = createEntry(player); controls.Entries[player] = entry end
			local selected, protected = State.SelectedPlayers[player] == true, State.ManualAllies[player] == true
			local matchesFilter = controls.Filter == "ALL"
				or controls.Filter == "FOCUSED" and selected
				or controls.Filter == "PROTECTED" and protected
			-- Plain search: punctuation in a display name is never interpreted as a Lua pattern.
			local matchesQuery = controls.Query == ""
				or string.find(string.lower(player.DisplayName), controls.Query, 1, true) ~= nil
				or string.find(string.lower("@" .. player.Name), controls.Query, 1, true) ~= nil
			entry.Card.Visible = matchesFilter and matchesQuery
			entry.Card.LayoutOrder = index
			if entry.Card.Visible then shown += 1 end
			entry.Name.Text = player.DisplayName
			entry.Username.Text = "@" .. player.Name
			entry.Detail.Text = protected and "Protegido da mira" or selected and "Escolhido por você"
				or ("Equipe: " .. Util.TeamName(player))
			entry.Detail.TextColor3 = protected and RelationColors.ALLY or selected and Theme.Accent2 or Theme.Sub
			entry.Card.BackgroundColor3 = selected and Theme.CardActive
				or protected and RelationColors.ALLY:Lerp(Theme.Card, 0.92) or Theme.Card
			entry.Stroke.Color = selected and Theme.AccentSoft or protected and RelationColors.ALLY or Theme.BorderSoft
			entry.Stroke.Transparency = (selected or protected) and 0.42 or 0.75
			entry.Focus.Text = selected and "Soltar" or "Focar"
			entry.Focus.Active = not protected
			entry.Focus.Selectable = not protected
			entry.Focus.TextTransparency = protected and 0.65 or 0
			entry.Focus.BackgroundColor3 = selected and Theme.AccentSoft or Theme.Surface3
			entry.Protect.Text = protected and "Desproteger" or "Proteger"
			entry.Protect.TextColor3 = protected and Theme.Text or RelationColors.ALLY
			entry.Protect.BackgroundColor3 = protected and RelationColors.ALLY:Lerp(Theme.Surface3, 0.60) or Theme.Surface3
			UI.LayoutPlayerEntry(entry, width)
		end
		controls.VisibleCount = shown
		controls.Empty.Visible = shown == 0
		controls.EmptyTitle.Text = counts.ALL == 0 and "Nenhum jogador por aqui"
			or controls.Query ~= "" and "Nenhum jogador encontrado"
			or controls.Filter == "FOCUSED" and "Nenhum jogador em foco"
			or "Nenhum jogador protegido"
		controls.EmptyHint.Text = counts.ALL == 0 and "Quem entrar na partida aparecerá aqui."
			or controls.Query ~= "" and "Tente outro nome ou limpe a busca."
			or controls.Filter == "FOCUSED" and "Em Todos, toque em Focar para escolher alguém."
			or "Em Todos, toque em Proteger para ignorar alguém."
		controls.Clear.Visible = controls.Search.Text ~= ""
		for _, data in ipairs(filterData) do
			local button = controls.Filters[data[1]]
			local active = controls.Filter == data[1]
			button.Text = data[2] .. " · " .. tostring(counts[data[1]])
			button.BackgroundTransparency = active and 0 or 1
			button.BackgroundColor3 = Theme.Surface3
			button.TextColor3 = active and Theme.Text or Theme.Sub
		end
		controls.TapSelect.BackgroundColor3 = Config.TapSelectPlayer and Theme.CardActive or Theme.Card
		controls.TapSwitch.BackgroundColor3 = Config.TapSelectPlayer and Theme.Accent or Theme.Chip
		controls.TapKnob.BackgroundColor3 = Config.TapSelectPlayer and Theme.Text or Theme.Muted
		controls.TapKnob.Position = UDim2.fromOffset(Config.TapSelectPlayer and 13 or 3, 3)
	end
	controls.Search:GetPropertyChangedSignal("Text"):Connect(function()
		controls.SearchGeneration += 1
		local generation = controls.SearchGeneration
		controls.Clear.Visible = controls.Search.Text ~= ""
		task.delay(0.08, function()
			if generation ~= controls.SearchGeneration or not Runtime.Alive or not page.Parent then return end
			controls.Query = string.lower(controls.Search.Text):match("^%s*(.-)%s*$")
			page.CanvasPosition = Vector2.zero
			controls.Refresh()
		end)
	end)
	controls.Clear.Activated:Connect(function() controls.Search.Text = "" end)
	controls.TapSelect.Activated:Connect(function()
		if State.UI.LayoutEditMode then return end
		UI.SetTapSelectPlayer(not Config.TapSelectPlayer)
		UI.Toast(Config.TapSelectPlayer and "Seleção por toque ativada." or "Seleção por toque desativada.")
	end)
	page:GetPropertyChangedSignal("Visible"):Connect(function()
		toolbar.Visible = page.Visible
		if not page.Visible then controls.Search:ReleaseFocus(false) end
	end)
	local lastWidth = -1
	local function layoutToolbar()
		local narrow = toolbar.AbsoluteSize.X < 320
		searchCard.Size = UDim2.new(1, narrow and 0 or -144, 0, 30)
		controls.TapSelect.Position = narrow and UDim2.fromOffset(0, 37) or UDim2.new(1, -136, 0, 0)
		controls.Help.Position = UDim2.new(1, 0, 0, narrow and 38 or 1)
		filters.Position = UDim2.fromOffset(0, narrow and 76 or 39)
		toolbar.Size = UDim2.new(1, -22, 0, narrow and 105 or 68)
		page.Position = UDim2.fromOffset(3, narrow and 116 or 79)
		page.Size = UDim2.new(1, -6, 1, narrow and -119 or -82)
	end
	toolbar:GetPropertyChangedSignal("AbsoluteSize"):Connect(layoutToolbar)
	layoutToolbar()
	controls.Container:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
		local width = controls.Container.AbsoluteSize.X
		if width == lastWidth then return end
		lastWidth = width
		for _, entry in pairs(controls.Entries) do UI.LayoutPlayerEntry(entry, width) end
	end)
	State.UI.PlayerDirectory = controls
	State.UI.RefreshPlayerDirectory = controls.Refresh
	State.UI.RefreshPlayers = function()
		controls.Refresh()
		UI.RefreshTargetSidebar()
	end
	State.UI.RefreshPlayers()
	return page
end

--==============================================================
-- UI WIRING
--==============================================================

function UI.RefreshMobileQuickControls()
	local holder = State.UI.MobileQuickControls

	if holder and holder.Parent then
		holder.Visible = Config.MobileQuickControls == true
	end

	local aimButton = State.UI.MobileAimButton
	if aimButton and aimButton.Parent then
		aimButton.Text = Config.AimEnabled and "MIRA ATIVA" or "MIRA DESL."
		aimButton.BackgroundColor3 =
			Config.AimEnabled and Theme.AccentSoft or Theme.Card
		aimButton.TextColor3 =
			Config.AimEnabled and Theme.Text or Theme.Sub
	end

	if State.UI.MobileAimStroke
		and State.UI.MobileAimStroke.Parent then
		State.UI.MobileAimStroke.Color =
			Config.AimEnabled and Theme.Accent or Theme.BorderSoft
		State.UI.MobileAimStroke.Transparency =
			Config.AimEnabled and 0.10 or 0.28
	end

	local lockButton = State.UI.MobileLockButton
	if lockButton and lockButton.Parent then
		lockButton.Text = Config.MobileQuickLocked and "FIXO" or "SOLTO"
		lockButton.BackgroundColor3 =
			Config.MobileQuickLocked and Theme.AccentSoft or Theme.Card
		lockButton.TextColor3 =
			Config.MobileQuickLocked and Theme.Text or Theme.Sub
	end

	if State.UI.MobileLockStroke
		and State.UI.MobileLockStroke.Parent then
		State.UI.MobileLockStroke.Color =
			Config.MobileQuickLocked and Theme.Accent or Theme.BorderSoft
		State.UI.MobileLockStroke.Transparency =
			Config.MobileQuickLocked and 0.10 or 0.28
	end
end

function UI.SetMobileQuickControlsVisible(visible)
	Config.MobileQuickControls = visible == true
	UI.RefreshMobileQuickControls()

	if State.UI.RefreshEngineControls then
		State.UI.RefreshEngineControls()
	end

	if State.UI.RefreshAimControls then
		State.UI.RefreshAimControls()
	end

	if State.UI.RefreshFilters then
		State.UI.RefreshFilters()
	end

	task.defer(UI.ClampMovableToViewport)
end

function UI.SetMobileQuickLocked(locked)
	Config.MobileQuickLocked = locked == true
	UI.RefreshMobileQuickControls()

	if State.UI.RefreshEngineControls then
		State.UI.RefreshEngineControls()
	end
end

function UI.SetMobileFriendlySwitch(enabled)
	local nextValue = enabled == true and S.UIS.TouchEnabled == true
	local changed = Config.MobileFriendlySwitch ~= nextValue
	Config.MobileFriendlySwitch = nextValue
	TargetSwipe.Cancel(nextValue and "Troca por gesto ativada" or "Troca por gesto desativada")
	if State.UI.RefreshEngineControls then State.UI.RefreshEngineControls() end
	if enabled and not nextValue then
		UI.Toast("A troca por gesto funciona somente em telas de toque.")
	elseif changed then
		UI.Toast(nextValue
			and "Deslize na direção do próximo alvo. Continue deslizando para trocar de novo."
			or "Troca por gesto desativada.")
	end
	return changed
end

function UI.RefreshQuick()
	if State.UI.CompactSub then
		State.UI.CompactSub.Text =
			Config.AimEnabled
			and "Mira ativada"
			or "Mira desativada"
	end

	if State.UI.CompactStatus then
		State.UI.CompactStatus.Text =
			Config.AimEnabled
			and "VISION X | MIRA ATIVA"
			or "VISION X | MENU"
	end

	UI.RefreshMobileQuickControls()
end

function UI.RefreshAimState()
	if State.UI.RefreshAimControls then
		State.UI.RefreshAimControls()
	end

	if State.UI.Status and State.UI.Status.Parent then
		State.UI.Status.Text =
			Config.AimEnabled
			and "Ativada • procurando alvo"
			or "Mira desativada"
	end

	if State.UI.StatusDot then
		State.UI.StatusDot.BackgroundColor3 =
			Config.AimEnabled and Theme.Success or Theme.Muted
	end

	if State.UI.StatusMini then
		State.UI.StatusMini.Text = Config.AimEnabled and "ATIVADA" or "DESATIVADA"
		State.UI.StatusMini.TextColor3 =
			Config.AimEnabled and Theme.Success or Theme.Sub
	end

	UI.RefreshQuick()
end

function UI.SetAimEnabled(enabled, reason, allowDisable)
	local nextValue = enabled == true

	if not nextValue
		and State.AimActivationIntent
		and allowDisable ~= true then

		Config.AimEnabled = true
		UI.RefreshAimState()
		return false
	end

	local changed = Config.AimEnabled ~= nextValue
	Config.AimEnabled = nextValue
	State.AimActivationIntent = nextValue

	if changed and not nextValue then
		TargetSwipe.Cancel(
			reason or "Assistência desativada"
		)
		Aim.ClearCurrentTarget(reason or "Assistência desativada")
	end

	UI.RefreshAimState()
	return changed
end

function UI.EnsureAimActivation()
	if State.AimActivationIntent and not Config.AimEnabled then
		Config.AimEnabled = true
		UI.RefreshAimState()
		return true
	end

	return false
end

function UI.SetPrimaryBodyRegion(region, options)
	if not BodyRegions[region] then
		return false
	end

	options = options or {}
	local rigName = BodyRigProfiles[Config.BodyRigMode]
		and Config.BodyRigMode
		or "R15"
	local currentPart = BodyRigProfiles.Find(
		rigName,
		Config.PrimaryBodyPartName
	)
	local partName =
		currentPart
		and currentPart.Region == region
		and currentPart.Name
		or BodyRigProfiles.DefaultForRegion(rigName, region)
	local changed = Config.PrimaryBodyRegion ~= region
		or Config.PrimaryBodyPartName ~= partName

	Config.BodyRigMode = rigName
	Config.PrimaryBodyRegion = region
	Config.PrimaryBodyPartName = partName
	Config.BodyRegionEnabled = Config.BodyRegionEnabled or {}
	Config.BodyRegionEnabled[region] = true

	if changed and options.MarkCustomized ~= false then
		Aim.MarkAssistantCustomized()
	end

	if changed and options.ClearTarget ~= false then
		Aim.ClearCurrentTarget(
			options.Reason or "Foco corporal alterado"
		)
	end

	if State.UI.SyncBodySelection then
		State.UI.SyncBodySelection(partName, rigName)
	elseif State.UI.RefreshBodyControls then
		State.UI.RefreshBodyControls()
	end

	if State.UI.RefreshAimControls then
		State.UI.RefreshAimControls()
	end

	if State.UI.RefreshAssistantControls then
		State.UI.RefreshAssistantControls()
	end

	return changed
end

function UI.SetPrimaryBodyPart(partName, options)
	options = options or {}
	local rigName, normalizedPart, region = BodyRigProfiles.Normalize(
		options.RigMode or Config.BodyRigMode,
		partName,
		Config.PrimaryBodyRegion
	)
	local changed = Config.PrimaryBodyRegion ~= region
		or Config.PrimaryBodyPartName ~= normalizedPart
		or Config.BodyRigMode ~= rigName

	Config.BodyRigMode = rigName
	Config.PrimaryBodyPartName = normalizedPart
	Config.PrimaryBodyRegion = region
	Config.BodyRegionEnabled = Config.BodyRegionEnabled or {}
	Config.BodyRegionEnabled[region] = true

	if changed and options.MarkCustomized ~= false then
		Aim.MarkAssistantCustomized()
	end

	if changed and options.ClearTarget ~= false then
		Aim.ClearCurrentTarget(
			options.Reason or "Parte corporal alterada"
		)
	end

	if State.UI.SyncBodySelection then
		State.UI.SyncBodySelection(normalizedPart, rigName)
	elseif State.UI.RefreshBodyControls then
		State.UI.RefreshBodyControls()
	end

	if State.UI.RefreshAimControls then
		State.UI.RefreshAimControls()
	end

	if State.UI.RefreshAssistantControls then
		State.UI.RefreshAssistantControls()
	end

	return changed
end

State.UI.SetPrimaryBodyRegion = UI.SetPrimaryBodyRegion
State.UI.SetPrimaryBodyPart = UI.SetPrimaryBodyPart

function UI.SetTapSelectPlayer(enabled)
	local nextValue = enabled == true
	local changed = Config.TapSelectPlayer ~= nextValue
	Config.TapSelectPlayer = nextValue

	if State.UI.RefreshPlayers then
		State.UI.RefreshPlayers()
	end

	return changed
end

function UI.RefreshAllControls()
	-- Aim state already refreshes its controls and mobile shortcuts. Players
	-- already refresh the target sidebar; team/filter callbacks are aliases.
	local seen = {}
	for _, name in ipairs({
		"RefreshAssistantControls", "RefreshBodyControls", "RefreshEngineControls",
		"RefreshESPControls", "RefreshPlayers", "RefreshTeams", "RefreshConfigurationControls",
	}) do
		local refresh = State.UI[name]
		if refresh and not seen[refresh] then
			seen[refresh] = true
			refresh()
		end
	end
	UI.RefreshAimState()
	if not State.UI.RefreshPlayers then UI.RefreshTargetSidebar() end
	if not State.UI.RefreshTeams then UI.RefreshTeamSidebar() end
end

function UI.ApplyConfigurationState(message, resetLayout)
	Config.UITheme = ThemePresets[Config.UITheme] and Config.UITheme or "RED"
	Config.MenuLayoutStyle = MENU_LAYOUT_PRESETS[Config.MenuLayoutStyle]
		and Config.MenuLayoutStyle
		or "BALANCED"
	Config.FOVStyle = FOV_STYLE_LABELS[Config.FOVStyle]
		and Config.FOVStyle
		or "TACTICAL"
	Config.ShowFOVCircle = Config.ShowFOVCircle ~= false
	Config.MenuScale = math.clamp(
		Persistence.FiniteNumber(Config.MenuScale, 1),
		MENU_SCALE_MIN,
		MENU_SCALE_MAX
	)
	Config.ControlScale = math.clamp(
		Persistence.FiniteNumber(Config.ControlScale, 0.90),
		CONTROL_SCALE_MIN,
		CONTROL_SCALE_MAX
	)
	Config.BodyRigMode,
		Config.PrimaryBodyPartName,
		Config.PrimaryBodyRegion = BodyRigProfiles.Normalize(
			Config.BodyRigMode,
			Config.PrimaryBodyPartName,
			Config.PrimaryBodyRegion
		)

	for player in pairs(State.SelectedPlayers) do
		State.SelectedPlayers[player] = nil
	end
	Config.AimMode = "AUTO"

	State.ActiveQuickPresetKey = nil
	TargetSwipe.Cancel(
		message or "Configuração atualizada"
	)
	Aim.ClearCurrentTarget(message or "Configuração atualizada")
	UI.SetControlOrganizerEnabled(false)
	UI.ApplyTheme(Config.UITheme)
	UI.ApplyFOVStyle(Config.FOVStyle)
	UI.ApplyControlScale(Config.ControlScale)
	if State.UI.ApplyMenuLayoutStyle then
		State.UI.ApplyMenuLayoutStyle(Config.MenuLayoutStyle)
	end

	if State.UI.SyncBodySelection then
		State.UI.SyncBodySelection(
			Config.PrimaryBodyPartName,
			Config.BodyRigMode
		)
	end

	if resetLayout then
		UI.ResetControlLayout()
		if State.UI.ResetWindowLayout then
			State.UI.ResetWindowLayout()
		end
	else
		UI.ApplySavedControlLayout()
		if State.UI.ApplyMenuScale then
			State.UI.ApplyMenuScale(Config.MenuScale, false)
		end
	end

	UI.RefreshAllControls()
	ESP.RefreshAll()

	if message then
		UI.Toast(message)
	end
end

function UI.PlayerFromWorldInstance(instance)
	local current = instance

	while current and current ~= S.Workspace do
		if current:IsA("Model") then
			local player =
				S.Players:GetPlayerFromCharacter(current)

			if player and player ~= S.LocalPlayer then
				return player
			end
		end

		current = current.Parent
	end

	return nil
end

function UI.IsPointOverInteractiveUI(screenPoint, includeExternalButtons)
	if State.UI.ActiveHelpDialog or State.UI.ActiveChoiceMenu then return true end
	local function inside(guiObject)
		if not guiObject
			or not guiObject.Parent
			or not guiObject.Visible then

			return false
		end

		local position = guiObject.AbsolutePosition
		local size = guiObject.AbsoluteSize

		return screenPoint.X >= position.X
			and screenPoint.X <= position.X + size.X
			and screenPoint.Y >= position.Y
			and screenPoint.Y <= position.Y + size.Y
	end

	-- These checks also protect executors that do not expose
	-- GetGuiObjectsAtPosition reliably.
	if inside(State.UI.Main)
		or inside(State.UI.CompactBar)
		or inside(State.UI.MobileQuickControls) then

		return true
	end

	local ok, guiObjects = pcall(function()
		return S.PlayerGui:GetGuiObjectsAtPosition(
			math.floor(screenPoint.X + 0.5),
			math.floor(screenPoint.Y + 0.5)
		)
	end)

	if not ok or not guiObjects then
		return false
	end

	local root = State.UI.Root

	for _, guiObject in ipairs(guiObjects) do
		local belongsToVision = root
			and guiObject:IsDescendantOf(root)
		local isFOV = State.UI.FOV
			and (
				guiObject == State.UI.FOV
				or guiObject:IsDescendantOf(State.UI.FOV)
			)
		local isVisionControl = belongsToVision
			and (
				guiObject:IsA("GuiButton")
				or guiObject:IsA("TextBox")
				or guiObject.Active
			)
		local isExternalButton = includeExternalButtons == true
			and not belongsToVision
			and (
				guiObject:IsA("GuiButton")
				or guiObject:IsA("TextBox")
			)

		if not isFOV
			and guiObject.Visible
			and (isVisionControl or isExternalButton) then

			return true
		end
	end

	return false
end

function UI.ProjectPartScreenBounds(part)
	if not S.Camera
		or not part
		or not part:IsA("BasePart")
		or not part.Parent then

		return nil
	end

	local centerProjected =
		S.Camera:WorldToViewportPoint(part.Position)

	if centerProjected.Z <= 0.01 then
		return nil
	end

	local half = part.Size * 0.5
	local minX = math.huge
	local minY = math.huge
	local maxX = -math.huge
	local maxY = -math.huge
	local nearestDepth = math.huge
	local projectedCorners = 0

	for x = -1, 1, 2 do
		for y = -1, 1, 2 do
			for z = -1, 1, 2 do
				local worldPoint =
					(
						part.CFrame
						* CFrame.new(
							half.X * x,
							half.Y * y,
							half.Z * z
						)
					).Position

				local projected =
					S.Camera:WorldToViewportPoint(worldPoint)

				if projected.Z > 0.01 then
					projectedCorners += 1
					minX = math.min(minX, projected.X)
					minY = math.min(minY, projected.Y)
					maxX = math.max(maxX, projected.X)
					maxY = math.max(maxY, projected.Y)
					nearestDepth = math.min(
						nearestDepth,
						projected.Z
					)
				end
			end
		end
	end

	if projectedCorners == 0 then
		return nil
	end

	return minX, minY, maxX, maxY, nearestDepth
end

function UI.ResolvePlayerAtScreenPoint(screenPoint)
	S.Camera = S.Workspace.CurrentCamera

	if not S.Camera then
		return nil
	end

	local viewport = S.Camera.ViewportSize
	if screenPoint.X < 0
		or screenPoint.Y < 0
		or screenPoint.X > viewport.X
		or screenPoint.Y > viewport.Y then

		return nil
	end

	local ray = S.Camera:ViewportPointToRay(
		screenPoint.X,
		screenPoint.Y
	)

	local rayParams = RaycastParams.new()
	rayParams.FilterType = Enum.RaycastFilterType.Exclude
	rayParams.IgnoreWater = true

	local ignored = {S.Camera}
	local ownCharacter = S.LocalPlayer.Character
	if ownCharacter then
		ignored[#ignored + 1] = ownCharacter
	end
	rayParams.FilterDescendantsInstances = ignored

	local directResult = S.Workspace:Raycast(
		ray.Origin,
		ray.Direction * 10000,
		rayParams
	)

	if directResult then
		local directPlayer =
			UI.PlayerFromWorldInstance(directResult.Instance)

		if directPlayer then
			local directRecord = State.Records[directPlayer]
			if PlayerCache.IsAlive(directRecord) then
				return directPlayer
			end
		end
	end

	-- Fallback for thin limbs on small touchscreens. It uses the actual
	-- projected bounds of every visible body part plus only a tiny padding.
	local bestPlayer = nil
	local bestScore = math.huge
	local padding = math.max(Config.TapSelectPadding or 0, 0)

	for _, player in ipairs(S.Players:GetPlayers()) do
		local record = State.Records[player]

		if player ~= S.LocalPlayer
			and PlayerCache.IsAlive(record) then

			local seenParts = {}

			for _, regionName in ipairs(BodyRegionOrder) do
				for _, part in ipairs(
					(record.BodyParts and record.BodyParts[regionName])
						or {}
				) do
					if not seenParts[part]
						and PlayerCache.PartBelongsToRecord(record, part)
						and part.Name ~= "HumanoidRootPart"
						and part.Transparency < 0.94 then

						seenParts[part] = true

						local minX, minY, maxX, maxY, depth =
							UI.ProjectPartScreenBounds(part)

						if minX
							and minY
							and maxX
							and maxY
							and depth
							and screenPoint.X >= minX - padding
							and screenPoint.X <= maxX + padding
							and screenPoint.Y >= minY - padding
							and screenPoint.Y <= maxY + padding
							and Aim.PointVisible(
								record,
								part.Position,
								true
								) then
								local lowerX = minX or screenPoint.X
								local upperX = maxX or screenPoint.X
								local lowerY = minY or screenPoint.Y
								local upperY = maxY or screenPoint.Y

								local nearestX = math.clamp(
									screenPoint.X,
									lowerX,
									upperX
								)
								local nearestY = math.clamp(
									screenPoint.Y,
									lowerY,
									upperY
							)
							local edgeDistance =
								(
									Vector2.new(nearestX, nearestY)
									- screenPoint
								).Magnitude

							local score =
								edgeDistance * 10000
								+ depth

							if score < bestScore
								or (
									score == bestScore
									and bestPlayer
									and player.UserId < bestPlayer.UserId
								) then

								bestScore = score
								bestPlayer = player
							end
						end
					end
				end
			end
		end
	end

	return bestPlayer
end

function UI.SetManualAlly(player, enabled)
	if not player
		or player == S.LocalPlayer
		or player.Parent ~= S.Players then

		return false
	end

	local isAlly = enabled == true
	local wasSelected = State.SelectedPlayers[player] == true
	local changed =
		(State.ManualAllies[player] == true) ~= isAlly

	if isAlly then
		State.ManualAllies[player] = true
		State.SelectedPlayers[player] = nil

		if wasSelected and Config.AimMode == "SELECTED" then
			Config.AimMode = "AUTO"
		end

		if State.CurrentTarget == player then
			Aim.ClearCurrentTarget(
				"Jogador protegido"
			)
		end
	else
		State.ManualAllies[player] = nil
	end

	if not changed then
		return false
	end

	ESP.RefreshAll()

	if State.UI.RefreshPlayers then
		State.UI.RefreshPlayers()
	else
		UI.RefreshTargetSidebar()
	end

	if State.UI.RefreshFilters then
		State.UI.RefreshFilters()
	else
		UI.RefreshTeamSidebar()
	end

	if State.UI.RefreshAimControls then
		State.UI.RefreshAimControls()
	end

	UI.Toast(
		isAlly
		and (player.DisplayName .. " foi protegido.")
		or (player.DisplayName .. " pode ser escolhido novamente.")
	)

	return true
end

function UI.ToggleManualAlly(player)
	return UI.SetManualAlly(
		player,
		not (State.ManualAllies[player] == true)
	)
end

function UI.SelectExclusivePlayer(player, source)
	if not player
		or player == S.LocalPlayer
		or player.Parent ~= S.Players then

		return false
	end

	if State.ManualAllies[player] then
		UI.Toast(
			player.DisplayName
				.. " está protegido. Remova a proteção para focar."
		)
		return false
	end

	local record = State.Records[player]
	if not PlayerCache.IsAlive(record) then
		UI.Toast("Este jogador não está disponível agora.")
		return false
	end

	for selectedPlayer in pairs(State.SelectedPlayers) do
		State.SelectedPlayers[selectedPlayer] = nil
	end

	State.SelectedPlayers[player] = true
	Config.AimMode = "SELECTED"
	Config.StickyTarget = true
	Config.SelectedESP = true

	Aim.ClearCurrentTarget(
		source or "Jogador selecionado diretamente"
	)
	UI.SetAimEnabled(true)

	-- Seed the chosen target immediately; the normal scan loop keeps it
	-- validated and reacquires its configured body region as the rig moves.
	local bodyResult = Aim.ResolveBestBodyPoint(record)
	if bodyResult then
		State.CurrentTarget = player
		State.CurrentPart = bodyResult.Part
		State.CurrentRegion = bodyResult.Region
		State.CurrentLocalOffset =
			bodyResult.Part.CFrame:PointToObjectSpace(
				bodyResult.Point
			)
		State.LastTargetSeen = os.clock()
		State.LastTargetVisible = os.clock()
		State.Debug.LastReason = "Alvo escolhido por toque"
	end

	ESP.RefreshAll()

	if State.UI.RefreshPlayers then
		State.UI.RefreshPlayers()
	else
		UI.RefreshTargetSidebar()
	end

	if State.UI.RefreshEngineControls then
		State.UI.RefreshEngineControls()
	end

	if State.UI.RefreshESPControls then
		State.UI.RefreshESPControls()
	end

	if State.UI.Status and State.UI.Status.Parent then
		State.UI.Status.Text =
			"Alvo escolhido: " .. player.DisplayName
	end

	UI.RefreshQuick()
	UI.Toast("Agora em foco: " .. player.DisplayName)
	return true
end

State.UI.SelectExclusivePlayer = UI.SelectExclusivePlayer

function UI.WireWorldTapSelection()
	local inputs = {}
	local owner = nil
	local mouseInput = nil
	local refreshPending = false

	local function pointOf(input)
		return Vector2.new(input.Position.X, input.Position.Y)
	end

	local function reset()
		table.clear(inputs)
		owner = nil
		mouseInput = nil
	end
	State.UI.ResetWorldGestureInput = reset

	State.UI.OnSwipeTargetChanged = function(_player, selectionChanged)
		if not selectionChanged or refreshPending then return end
		refreshPending = true
		task.defer(function()
			refreshPending = false
			if not Runtime.Alive then return end
			ESP.RefreshAll()
			if State.UI.RefreshPlayers then State.UI.RefreshPlayers() end
			if State.UI.RefreshAimControls then State.UI.RefreshAimControls() end
		end)
	end

	local function blocked(point)
		if State.UI.LayoutEditMode or UI.IsPointOverInteractiveUI(point, false) then return true end
		local ok, objects = pcall(function()
			return S.PlayerGui:GetGuiObjectsAtPosition(math.floor(point.X), math.floor(point.Y))
		end)
		if ok and objects and S.Camera then
			local viewport = S.Camera.ViewportSize
			for _, object in ipairs(objects) do
				if (object:IsA("GuiButton") or object:IsA("TextBox"))
					and UI.PointInside(object, point) then
					local size = object.AbsoluteSize
					-- Reject actual jump/fire/menu buttons without rejecting a
					-- game's full-screen transparent camera-capture surface.
					if size.X * size.Y < viewport.X * viewport.Y * 0.3 then return true end
				end
			end
		end
		return false
	end

	local function cameraArea(point)
		local camera = S.Workspace.CurrentCamera
		if not camera then return false end
		local viewport = camera.ViewportSize
		return point.X >= viewport.X * Config.MobileFriendlyStartArea
			and point.X <= viewport.X and point.Y >= 0 and point.Y <= viewport.Y
	end

	local function update(input, position)
		local entry = inputs[input]
		if not entry then return end
		local point = position or pointOf(input)
		if point.X == entry.Last.X and point.Y == entry.Last.Y then return end
		entry.Last = point
		entry.MaxTravel = math.max(entry.MaxTravel, (point - entry.Start).Magnitude)
		if input ~= owner or not entry.Swipe then return end
		if not TargetSwipe.CanReceiveInput() then
			entry.Origin = point
			return
		end
		local camera = S.Workspace.CurrentCamera
		if entry.Camera ~= camera then
			entry.Camera, entry.Reference, entry.Origin = camera, camera.CFrame, point
			return
		end
		local movement = point - entry.Origin
		local threshold = Config.MobileFriendlyMoveThreshold
		if math.abs(movement.Y) >= threshold
			and math.abs(movement.X) < math.abs(movement.Y) * Config.MobileFriendlyHorizontalRatio then
			-- A vertical camera movement must not leave a large diagonal offset
			-- that swallows the next deliberate horizontal pull.
			entry.Origin, entry.Reference = point, camera.CFrame
			return
		end
		if math.abs(movement.X) < threshold
			or math.abs(movement.X) < math.abs(movement.Y) * Config.MobileFriendlyHorizontalRatio then
			return
		end

		-- Consume one deliberate pull before calling any other code. Duplicate
		-- events, frame polling and a stationary finger then cannot repeat it.
		entry.Origin = point
		entry.Swiped = true
		local reference = entry.Reference
		entry.Reference = S.Workspace.CurrentCamera.CFrame
		TargetSwipe.Request(movement.X, reference)
	end

	local function ended(input, cancelled)
		local entry = inputs[input]
		if not entry then return end
		if not cancelled and input.UserInputType == Enum.UserInputType.Touch then update(input) end
		inputs[input] = nil
		if owner == input then owner = nil end
		if mouseInput == input then mouseInput = nil end
		if not cancelled and entry.Tap and Config.TapSelectPlayer
			and not entry.Swiped and entry.MaxTravel <= Config.TapSelectMoveThreshold
			and os.clock() - entry.StartedAt <= Config.TapSelectMaxDuration
			and not blocked(entry.Last) then
			local player = entry.PressedPlayer or UI.ResolvePlayerAtScreenPoint(entry.Last)
			if player then UI.SelectExclusivePlayer(player, "Jogador selecionado na tela") end
		end
	end

	local function began(input, processed)
		local isTouch = input.UserInputType == Enum.UserInputType.Touch
		local isMouse = input.UserInputType == Enum.UserInputType.MouseButton1
		if inputs[input] or (not isTouch and not isMouse) or (isMouse and processed) then return end
		local point = pointOf(input)
		if blocked(point) then return end
		local canSwipe = isTouch and TargetSwipe.CanReceiveInput() and cameraArea(point)
		local canTap = Config.TapSelectPlayer == true and (not processed or canSwipe)
		if not canSwipe and not canTap then return end
		if owner and (owner.UserInputState == Enum.UserInputState.End
			or owner.UserInputState == Enum.UserInputState.Cancel) then
			ended(owner, true)
		end
		inputs[input] = {
			Start = point, Last = point, Origin = point, MaxTravel = 0,
			StartedAt = os.clock(), Tap = canTap, Swipe = canSwipe,
			Swiped = false, Reference = S.Workspace.CurrentCamera and S.Workspace.CurrentCamera.CFrame,
			Camera = S.Workspace.CurrentCamera,
			PressedPlayer = canTap and UI.ResolvePlayerAtScreenPoint(point) or nil,
		}
		if canSwipe and not owner then owner = input end
		if isMouse then mouseInput = input end
	end

	local function changed(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement then
			if mouseInput then update(mouseInput, pointOf(input)) end
		elseif input.UserInputState == Enum.UserInputState.Cancel then
			ended(input, true)
		elseif input.UserInputState == Enum.UserInputState.End then
			ended(input, false)
		else
			update(input)
		end
	end

	local function finished(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 and mouseInput then
			update(mouseInput, pointOf(input))
			ended(mouseInput, input.UserInputState == Enum.UserInputState.Cancel)
		else
			ended(input, input.UserInputState == Enum.UserInputState.Cancel)
		end
	end

	local function guarded(callback)
		return function(...)
			if not Runtime.Alive then return end
			local ok, message = pcall(callback, ...)
			if not ok then
				reset()
				State.LastRuntimeError = string.sub(tostring(message), 1, 240)
				State.Swipe.LastResult = "Toque reiniciado; mira mantida"
			end
		end
	end

	-- The input object is the finger's identity. Both event families may
	-- report it; the registry and consumed origin make delivery idempotent.
	Runtime.Track(S.UIS.InputBegan:Connect(guarded(began)))
	Runtime.Track(S.UIS.TouchStarted:Connect(guarded(began)))
	Runtime.Track(S.UIS.InputChanged:Connect(guarded(changed)))
	Runtime.Track(S.UIS.TouchMoved:Connect(guarded(changed)))
	Runtime.Track(S.UIS.InputEnded:Connect(guarded(finished)))
	Runtime.Track(S.UIS.TouchEnded:Connect(guarded(finished)))
	Runtime.Track(S.UIS.WindowFocusReleased:Connect(reset))

	State.UI.PollWorldGestureInput = guarded(function()
		for input in pairs(inputs) do
			if input.UserInputType == Enum.UserInputType.Touch then changed(input) end
		end
	end)
end

local function BuildNavigation()
	State.UI.Pages = {
		Aim = Pages.BuildVisionAim(),
		Assistant = Pages.BuildAssistant(),
		Body = Pages.BuildBody(),
		Engine = Pages.BuildEngine(),
		ESP = Pages.BuildESP(),
		Players = Pages.BuildPlayers(),
	}
	State.UI.RefreshFilters = function()
		UI.RefreshTeamSidebar()
	end
	State.UI.RefreshTeams = function()
		UI.RefreshTeamSidebar()
	end

	State.UI.Nav = {
		Aim = UI.CreateNavButton("MIRA"),
		Assistant = UI.CreateNavButton("PERFIS"),
		Body = UI.CreateNavButton("CORPO"),
		Players = UI.CreateNavButton("JOGADORES"),
		ESP = UI.CreateNavButton("ESP"),
		Engine = UI.CreateNavButton("AJUSTES"),
	}

	State.UI.PageMap = {
		[State.UI.Nav.Aim] = State.UI.Pages.Aim,
		[State.UI.Nav.Assistant] = State.UI.Pages.Assistant,
		[State.UI.Nav.Body] = State.UI.Pages.Body,
		[State.UI.Nav.Engine] = State.UI.Pages.Engine,
		[State.UI.Nav.ESP] = State.UI.Pages.ESP,
		[State.UI.Nav.Players] = State.UI.Pages.Players,
	}

	local navOrder = {
		"Aim",
		"Assistant",
		"Body",
		"Players",
		"ESP",
		"Engine",
	}

	local refreshers = {
		Aim = "RefreshAimControls",
		Assistant = "RefreshAssistantControls",
		Body = "RefreshBodyControls",
		Engine = "RefreshEngineControls",
		ESP = "RefreshESPControls",
		Players = "RefreshPlayers",
	}

	for index, name in ipairs(navOrder) do
		local button = State.UI.Nav[name]
		button.LayoutOrder = index

		button.MouseButton1Click:
			Connect(function()
				local refreshName = refreshers[name]
				local refresh = refreshName and State.UI[refreshName]
				if refresh then
					refresh()
				end

				UI.ShowPage(
					State.UI.Pages[name]
				)
			end)
	end

	UI.ShowPage(
		State.UI.Pages.Aim
	)
	UI.InitializeControlOrganizer()

	UI.RefreshTargetSidebar()
	UI.RefreshTeamSidebar()

	if State.UI.TargetSearch then
		State.UI.TargetSearch:GetPropertyChangedSignal("Text"):
			Connect(function()
				State.TargetSearchGeneration += 1
				local generation = State.TargetSearchGeneration

				task.delay(0.12, function()
					if Runtime.Alive
						and generation == State.TargetSearchGeneration then

						UI.RefreshTargetSidebar()
					end
				end)
			end)
	end
end

--==============================================================
-- MAIN WINDOW / TOUCH EVENTS
--==============================================================

local function WireVisionGeneralUI()
	local minimized = false
	local maximized = false
	local expandedSize = State.UI.Main.Size
	local expandedPosition = State.UI.Main.Position
	local normalMinSize = Vector2.new(560, 260)
	local normalMaxSize = Vector2.new(1500, 820)
	local normalFill = 0.84
	local maximizedFill = 0.97
	local manualSize = nil
	local maximizeGeneration = 0
	local maximizeTransitioning = false
	local menuScaleTween = nil
	local menuScaleGeneration = 0

	local function configuredManualSize()
		local width = Persistence.FiniteNumber(Config.MenuCustomWidth, 0)
		local height = Persistence.FiniteNumber(Config.MenuCustomHeight, 0)

		if Config.MenuSizeMode == "CUSTOM"
			and width > 0
			and height > 0 then

			return Vector2.new(width, height)
		end

		return nil
	end

	local function fitManualSizeToViewport(size)
		local viewport = S.Camera and S.Camera.ViewportSize
			or Vector2.new(800, 450)
		local maximum = Vector2.new(
			math.max(math.min(normalMaxSize.X, viewport.X - 12), 1),
			math.max(math.min(normalMaxSize.Y, viewport.Y - 12), 1)
		)
		local minimum = Vector2.new(
			math.min(normalMinSize.X, maximum.X),
			math.min(normalMinSize.Y, maximum.Y)
		)

		return Vector2.new(
			math.clamp(size.X, minimum.X, maximum.X),
			math.clamp(size.Y, minimum.Y, maximum.Y)
		)
	end

	manualSize = configuredManualSize()

	local function setMaximizeConstraint()
		local constraint = State.UI.MainSizeConstraint
		if not constraint or not constraint.Parent then
			return
		end

		local viewport =
			S.Camera and S.Camera.ViewportSize
			or Vector2.new(800, 450)
		constraint.MinSize = Vector2.new(
			math.min(normalMinSize.X, math.max(viewport.X - 12, 1)),
			math.min(normalMinSize.Y, math.max(viewport.Y - 12, 1))
		)
		constraint.MaxSize = normalMaxSize
	end
	setMaximizeConstraint()

	State.UI.ApplyMenuScale = function(value, instant)
		Config.MenuScale = math.clamp(
			Persistence.FiniteNumber(value, 1),
			MENU_SCALE_MIN,
			MENU_SCALE_MAX
		)
		manualSize = configuredManualSize()
		local fittedManualSize = manualSize
			and fitManualSizeToViewport(manualSize)
		local targetSize = fittedManualSize
			and UDim2.fromOffset(
				fittedManualSize.X,
				fittedManualSize.Y
			)
			or GetVisionMenuSize(normalFill, Config.MenuScale)
		expandedSize = targetSize
		menuScaleGeneration += 1
		local generation = menuScaleGeneration

		if maximized or not State.UI.Main.Visible then
			return targetSize
		end

		if menuScaleTween then
			pcall(function()
				menuScaleTween:Cancel()
			end)
			menuScaleTween = nil
		end

		if instant then
			State.UI.Main.Size = targetSize
			UI.ClampMovableToViewport()
		else
			menuScaleTween = Util.Tween(
				State.UI.Main,
				{Size = targetSize},
				0.11
			)
			task.delay(0.13, function()
				if Runtime.Alive
					and generation == menuScaleGeneration
					and State.UI.Main
					and State.UI.Main.Parent then

					menuScaleTween = nil
					UI.ClampMovableToViewport()
				end
			end)
		end

		return targetSize
	end

	State.UI.ResetWindowLayout = function()
		minimized = false
		maximized = false
		maximizeTransitioning = false
		maximizeGeneration += 1
		manualSize = nil
		expandedPosition = UDim2.fromScale(0.5, 0.52)
		State.UI.Main.Position = expandedPosition
		State.UI.Main.Visible = true
		State.UI.CompactBar.Visible = false
		State.UI.CompactBar.Position = UDim2.fromScale(0.5, 0.09)
		State.UI.MobileQuickControls.Position = UDim2.new(0, 16, 0.62, 0)
		State.UI.Maximize.Text = "+"
		if State.UI.ResizeHandle then
			State.UI.ResizeHandle.Visible = true
		end
		if State.UI.TargetSearch then
			State.UI.TargetSearch.Text = ""
		end
		for _, rail in ipairs({State.UI.LeftRail, State.UI.RightRail}) do
			if rail then
				rail.CanvasPosition = Vector2.zero
			end
		end
		if State.UI.Pages then
			for _, page in pairs(State.UI.Pages) do
				if page and page:IsA("ScrollingFrame") then
					page.CanvasPosition = Vector2.zero
				end
			end
			if State.UI.Pages.Aim then
				UI.ShowPage(State.UI.Pages.Aim)
			end
		end
		setMaximizeConstraint()
		State.UI.ApplyMenuScale(Config.MenuScale, true)
		task.defer(UI.ClampMovableToViewport)
	end

	State.UI.Minimize.MouseButton1Click:Connect(function()
		if minimized then
			return
		end

		if not maximized then
			expandedSize = State.UI.Main.Size
			expandedPosition = State.UI.Main.Position
		end

		minimized = true
		State.UI.CompactSub.Text = State.UI.Status.Text
		State.UI.Main.Visible = false
		State.UI.CompactBar.Visible = true
		task.defer(UI.ClampMovableToViewport)
	end)

	State.UI.CompactOpen.MouseButton1Click:Connect(function()
		if not minimized then
			return
		end
		minimized = false
		State.UI.CompactBar.Visible = false
		setMaximizeConstraint()
		State.UI.Main.Visible = true
		State.UI.Main.Size =
			maximized
			and GetVisionMenuSize(maximizedFill, 1)
			or expandedSize
		State.UI.Main.Position = maximized and UDim2.fromScale(0.5, 0.52) or expandedPosition
		task.defer(UI.ClampMovableToViewport)
	end)

	if State.UI.Maximize then
		State.UI.Maximize.MouseButton1Click:Connect(function()
			if maximizeTransitioning then
				return
			end

			maximizeTransitioning = true
			maximized = not maximized
			maximizeGeneration += 1
			local generation = maximizeGeneration
			if maximized then
				expandedSize = State.UI.Main.Size
				expandedPosition = State.UI.Main.Position
				setMaximizeConstraint()
				Util.Tween(State.UI.Main, {
					Position = UDim2.fromScale(0.5, 0.52),
					Size = GetVisionMenuSize(maximizedFill, 1),
				}, 0.16)
				State.UI.Maximize.Text = "="
				if State.UI.ResizeHandle then
					State.UI.ResizeHandle.Visible = false
				end

				task.delay(0.18, function()
					if generation == maximizeGeneration then
						maximizeTransitioning = false
					end
				end)
			else
				Util.Tween(State.UI.Main, {
					Position = expandedPosition,
					Size = expandedSize,
				}, 0.16)
				State.UI.Maximize.Text = "+"
				if State.UI.ResizeHandle then
					State.UI.ResizeHandle.Visible = true
				end

				task.delay(0.18, function()
					if Runtime.Alive
						and not maximized
						and generation == maximizeGeneration then

						setMaximizeConstraint()
						State.UI.Main.Size = expandedSize
						UI.ClampMovableToViewport()
						maximizeTransitioning = false
					end
				end)
			end
		end)
	end

	if State.UI.Close then
		State.UI.Close.MouseButton1Click:Connect(function()
			local root = State.UI.Root
			Runtime.Cleanup()

			if root and root.Parent then
				root:Destroy()
			end
		end)
	end

	local drag = {
		Menu = false,
		MenuInput = nil,
		MenuStart = nil,
		MenuOrigin = nil,
		Compact = false,
		CompactInput = nil,
		CompactStart = nil,
		CompactOrigin = nil,
		Quick = false,
		QuickInput = nil,
		QuickStart = nil,
		QuickOrigin = nil,
		QuickMoved = false,
		Resize = false,
		ResizeInput = nil,
		ResizeStart = nil,
		ResizeSize = nil,
		ResizeTopLeft = nil,
	}

	local function inputMatches(activeInput, changedInput)
		if not activeInput then
			return false
		end
		if activeInput.UserInputType == Enum.UserInputType.Touch then
			return changedInput == activeInput
		end
		return activeInput.UserInputType == Enum.UserInputType.MouseButton1
			and changedInput.UserInputType == Enum.UserInputType.MouseMovement
	end

	local function inputFinished(activeInput, endedInput)
		return activeInput == endedInput
			or (
				activeInput
				and activeInput.UserInputType == Enum.UserInputType.MouseButton1
				and endedInput.UserInputType == Enum.UserInputType.MouseButton1
			)
	end

	if State.UI.MobileAimButton then
		State.UI.MobileAimButton.MouseButton1Click:Connect(function()
			if drag.QuickMoved then
				drag.QuickMoved = false
				return
			end

			UI.SetAimEnabled(
				not State.AimActivationIntent,
				"Assistência desativada pelo botão móvel",
				true
			)
		end)
	end

	if State.UI.MobileLockButton then
		State.UI.MobileLockButton.MouseButton1Click:Connect(function()
			drag.Quick = false
			drag.QuickInput = nil
			drag.QuickMoved = false

			UI.SetMobileQuickLocked(not Config.MobileQuickLocked)

			UI.Toast(
				Config.MobileQuickLocked
				and "Atalhos fixados."
				or "Arraste o botão MIRA para mover."
			)
		end)
	end

	State.UI.HeaderDragArea.InputBegan:Connect(function(input)
		if maximized then
			return
		end
		if input.UserInputType == Enum.UserInputType.Touch
			or input.UserInputType == Enum.UserInputType.MouseButton1 then
			if drag.MenuInput and drag.MenuInput ~= input then
				return
			end

			drag.Menu = true
			drag.MenuInput = input
			drag.MenuStart = input.Position
			drag.MenuOrigin = State.UI.Main.Position
		end
	end)

	if State.UI.ResizeHandle then
		State.UI.ResizeHandle.InputBegan:Connect(function(input)
			if maximized or minimized then
				return
			end

			if input.UserInputType ~= Enum.UserInputType.Touch
				and input.UserInputType ~= Enum.UserInputType.MouseButton1 then
				return
			end

			if drag.ResizeInput and drag.ResizeInput ~= input then
				return
			end

			if menuScaleTween then
				pcall(function()
					menuScaleTween:Cancel()
				end)
				menuScaleTween = nil
			end

			drag.Resize = true
			drag.ResizeInput = input
			drag.ResizeStart = input.Position
			drag.ResizeSize = State.UI.Main.AbsoluteSize
			drag.ResizeTopLeft = State.UI.Main.AbsolutePosition
			State.UI.ResizeHandle.BackgroundTransparency = 0.24
		end)
	end

	State.UI.CompactDragArea.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.Touch
			or input.UserInputType == Enum.UserInputType.MouseButton1 then
			if drag.CompactInput and drag.CompactInput ~= input then
				return
			end

			drag.Compact = true
			drag.CompactInput = input
			drag.CompactStart = input.Position
			drag.CompactOrigin = State.UI.CompactBar.Position
		end
	end)

	State.UI.MobileQuickDragArea.InputBegan:Connect(function(input)
		drag.QuickMoved = false

		if Config.MobileQuickLocked then
			return
		end

		if input.UserInputType == Enum.UserInputType.Touch
			or input.UserInputType == Enum.UserInputType.MouseButton1 then
			if drag.QuickInput and drag.QuickInput ~= input then
				return
			end

			drag.Quick = true
			drag.QuickInput = input
			drag.QuickStart = input.Position
			drag.QuickOrigin = State.UI.MobileQuickControls.Position
		end
	end)

	Runtime.Track(S.UIS.InputChanged:Connect(function(input)
		if UI.ActiveSlider and inputMatches(UI.ActiveSliderInput, input) then
			local slider = UI.ActiveSlider
			local width = math.max(slider.Track.AbsoluteSize.X, 1)
			local alpha = math.clamp(
				(input.Position.X - slider.Track.AbsolutePosition.X) / width,
				0,
				1
			)
			local value = slider.Min + (slider.Max - slider.Min) * alpha
			slider:SetValue(value, true)
		end

		if drag.Menu and inputMatches(drag.MenuInput, input) then
			local delta = input.Position - drag.MenuStart
			local viewport = S.Camera and S.Camera.ViewportSize or Vector2.new(800, 450)
			local half = State.UI.Main.AbsoluteSize * 0.5
			local baseX = viewport.X * drag.MenuOrigin.X.Scale
			local baseY = viewport.Y * drag.MenuOrigin.Y.Scale
			local centerX = Util.ClampCenteredAxis(
				baseX + drag.MenuOrigin.X.Offset + delta.X,
				half.X,
				viewport.X,
				6
			)
			local centerY = Util.ClampCenteredAxis(
				baseY + drag.MenuOrigin.Y.Offset + delta.Y,
				half.Y,
				viewport.Y,
				6
			)
			State.UI.Main.Position = UDim2.new(
				drag.MenuOrigin.X.Scale,
				centerX - baseX,
				drag.MenuOrigin.Y.Scale,
				centerY - baseY
			)
		end

		if drag.Resize and inputMatches(drag.ResizeInput, input) then
			local viewport =
				S.Camera and S.Camera.ViewportSize
				or Vector2.new(800, 450)
			local delta = input.Position - drag.ResizeStart
			local constraint = State.UI.MainSizeConstraint
			local minimum =
				constraint and constraint.MinSize
				or normalMinSize
			local maximum = Vector2.new(
				math.max(math.min(normalMaxSize.X, viewport.X - 12), 1),
				math.max(math.min(normalMaxSize.Y, viewport.Y - 12), 1)
			)
			local minWidth = math.min(minimum.X, maximum.X)
			local minHeight = math.min(minimum.Y, maximum.Y)
			local width = math.clamp(
				drag.ResizeSize.X + delta.X,
				minWidth,
				maximum.X
			)
			local height = math.clamp(
				drag.ResizeSize.Y + delta.Y,
				minHeight,
				maximum.Y
			)
			local topLeft = drag.ResizeTopLeft
			local centerX = Util.ClampCenteredAxis(
				topLeft.X + width * 0.5,
				width * 0.5,
				viewport.X,
				6
			)
			local centerY = Util.ClampCenteredAxis(
				topLeft.Y + height * 0.5,
				height * 0.5,
				viewport.Y,
				6
			)

			manualSize = Vector2.new(width, height)
			Config.MenuSizeMode = "CUSTOM"
			Config.MenuCustomWidth = width
			Config.MenuCustomHeight = height
			State.UI.Main.Size = UDim2.fromOffset(width, height)
			State.UI.Main.Position = UDim2.fromOffset(centerX, centerY)
			expandedSize = State.UI.Main.Size
			expandedPosition = State.UI.Main.Position
		end

		if drag.Compact and inputMatches(drag.CompactInput, input) then
			local delta = input.Position - drag.CompactStart
			local viewport = S.Camera and S.Camera.ViewportSize or Vector2.new(800, 450)
			local compact = State.UI.CompactBar
			local size = compact.AbsoluteSize
			local anchor = compact.AnchorPoint
			local origin = drag.CompactOrigin
			local baseX = viewport.X * origin.X.Scale
			local baseY = viewport.Y * origin.Y.Scale
			local anchorX = Util.ClampAnchoredAxis(
				baseX + origin.X.Offset + delta.X,
				size.X,
				anchor.X,
				viewport.X,
				6
			)
			local anchorY = Util.ClampAnchoredAxis(
				baseY + origin.Y.Offset + delta.Y,
				size.Y,
				anchor.Y,
				viewport.Y,
				6
			)
			compact.Position = UDim2.new(
				origin.X.Scale,
				anchorX - baseX,
				origin.Y.Scale,
				anchorY - baseY
			)
		end

		if drag.Quick
			and not Config.MobileQuickLocked
			and inputMatches(drag.QuickInput, input) then
			local delta = input.Position - drag.QuickStart
			local distance = Vector2.new(delta.X, delta.Y).Magnitude

			if distance >= 7 then
				drag.QuickMoved = true
			end

			if drag.QuickMoved then
				local viewport =
					S.Camera and S.Camera.ViewportSize
					or Vector2.new(800, 450)

				local holder = State.UI.MobileQuickControls
				local size = holder.AbsoluteSize
				local anchor = holder.AnchorPoint
				local origin = drag.QuickOrigin
				local baseX = viewport.X * origin.X.Scale
				local baseY = viewport.Y * origin.Y.Scale

				local anchorX = Util.ClampAnchoredAxis(
					baseX + origin.X.Offset + delta.X,
					size.X,
					anchor.X,
					viewport.X,
					8
				)

				local anchorY = Util.ClampAnchoredAxis(
					baseY + origin.Y.Offset + delta.Y,
					size.Y,
					anchor.Y,
					viewport.Y,
					8
				)

				holder.Position = UDim2.new(
					origin.X.Scale,
					anchorX - baseX,
					origin.Y.Scale,
					anchorY - baseY
				)
			end
		end
	end))

	Runtime.Track(S.UIS.InputEnded:Connect(function(input)
		if inputFinished(UI.ActiveSliderInput, input) then
			UI.ActiveSlider = nil
			UI.ActiveSliderInput = nil
		end
		if inputFinished(drag.MenuInput, input) then
			drag.Menu = false
			drag.MenuInput = nil
		end
		if inputFinished(drag.CompactInput, input) then
			drag.Compact = false
			drag.CompactInput = nil
		end
		if inputFinished(drag.QuickInput, input) then
			drag.Quick = false
			drag.QuickInput = nil
		end
		if inputFinished(drag.ResizeInput, input) then
			drag.Resize = false
			drag.ResizeInput = nil
			drag.ResizeStart = nil
			drag.ResizeSize = nil
			drag.ResizeTopLeft = nil
			if State.UI.ResizeHandle then
				State.UI.ResizeHandle.BackgroundTransparency = 0.68
			end
			if State.UI.RefreshEngineControls then
				State.UI.RefreshEngineControls()
			end
			UI.ClampMovableToViewport()
		end
	end))

	local function refreshMenuForViewport()
		if not Runtime.Alive
			or not State.UI.Main
			or not State.UI.Main.Parent then

			return
		end

		setMaximizeConstraint()

		local targetSize
		if manualSize and not maximized then
			local fittedManualSize = fitManualSizeToViewport(manualSize)
			targetSize = UDim2.fromOffset(
				fittedManualSize.X,
				fittedManualSize.Y
			)
		else
			targetSize = GetVisionMenuSize(
				maximized and maximizedFill or normalFill,
				maximized and 1 or Config.MenuScale
			)
		end

		if maximized then
			State.UI.Main.Position = UDim2.fromScale(0.5, 0.52)
			local fittedManualSize = manualSize
				and fitManualSizeToViewport(manualSize)
			expandedSize = fittedManualSize
				and UDim2.fromOffset(
					fittedManualSize.X,
					fittedManualSize.Y
				)
				or GetVisionMenuSize(normalFill, Config.MenuScale)
			expandedPosition = UDim2.fromScale(0.5, 0.52)
		else
			expandedSize = targetSize
		end

		State.UI.Main.Size = targetSize
		task.defer(UI.ClampMovableToViewport)
	end

	local viewportConnection = nil
	local function bindViewport(camera)
		viewportConnection = Runtime.Untrack(viewportConnection)

		if camera then
			viewportConnection = Runtime.Track(
				camera:GetPropertyChangedSignal("ViewportSize"):
				Connect(refreshMenuForViewport)
			)
		end

		refreshMenuForViewport()
	end

	bindViewport(S.Camera)
	Runtime.Track(
		S.Workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
			S.Camera = S.Workspace.CurrentCamera
			bindViewport(S.Camera)
		end)
	)
end

local function RequestPlayerListRefresh()
	if not Runtime.Alive
		or not State.UI.Root
		or not State.UI.Root.Parent
		or State.PlayerListRefreshPending then

		return
	end

	if not State.UI.RefreshPlayers then
		return
	end

	State.PlayerListRefreshPending = true

	task.defer(function()
		State.PlayerListRefreshPending = false

		if Runtime.Alive
			and State.UI.Root
			and State.UI.Root.Parent
			and State.UI.RefreshPlayers then

			State.UI.RefreshPlayers()
		end
	end)
end

RequestRelationStateRefresh = function(reason)
	Util.InvalidateAllTeamIdentities()
	State.RelationRefreshReason =
		reason or State.RelationRefreshReason or "Relação de equipe alterada"

	if State.RelationRefreshPending then
		return
	end

	State.RelationRefreshPending = true
	task.defer(function()
		State.RelationRefreshPending = false
		local refreshReason = State.RelationRefreshReason
		State.RelationRefreshReason = nil

		if not Runtime.Alive then
			return
		end

		ESP.RefreshAll()
		RequestPlayerListRefresh()

		if State.CurrentTarget
			and not Aim.PlayerAllowed(State.CurrentTarget) then

			Aim.ClearCurrentTarget(refreshReason)
		end

		if State.UI.RefreshTeams then
			State.UI.RefreshTeams()
		else
			UI.RefreshTeamSidebar()
		end
	end)
end

--==============================================================
-- PLAYER SETUP
--==============================================================

-- The cache coalesces descendant changes into one refresh per scheduler turn.
-- This layer synchronizes visuals and health without repeating full scans.
BindImmediateESPCharacterEvents = function(player, record)
	local character =
		record and record.Character

	if not character
		or not character.Parent then

		return
	end

	local function bindHumanoidLifecycle()
		local humanoid = record.Humanoid

		if humanoid == record.LifecycleHumanoid then
			return
		end

		Runtime.Disconnect(record.HumanoidHealthConnection)
		record.HumanoidHealthConnection = nil
		record.LifecycleHumanoid = humanoid

		if not humanoid then
			return
		end

		record.HumanoidHealthConnection =
			humanoid.HealthChanged:
			Connect(function(health)
				if not Runtime.Alive
					or player.Parent ~= S.Players
					or record.Character ~= character
					or humanoid ~= record.LifecycleHumanoid then

					return
				end

				local alive = health > 0

				if record.LastAlive == alive then
					return
				end

				record.LastAlive = alive

				if alive then
					PlayerCache.RefreshBodyParts(record)
					ESP.SafeRefresh(player)
				else
					ESP.Clear(record)

					if State.CurrentTarget == player then
						Aim.ClearCurrentTarget(
							"Jogador morreu"
						)
					end
				end
			end)
	end

	local function syncVisuals(expectedCharacter)
		if not Runtime.Alive
			or player.Parent ~= S.Players
			or record.Character ~= character
			or expectedCharacter ~= character
			or not character.Parent then

			return
		end

		bindHumanoidLifecycle()

		local alive = PlayerCache.IsAlive(record)
		local changed = record.LastAlive ~= alive
		record.LastAlive = alive

		if not alive then
			ESP.Clear(record)

			if changed and State.CurrentTarget == player then
				Aim.ClearCurrentTarget(
					"Jogador morreu"
				)
			end

			return
		end

		ESP.SafeRefresh(player)
	end

	record.OnPartsRefreshed = syncVisuals

	local relationAttributeConnection =
		character.AttributeChanged:
		Connect(function(attributeName)
			if Universal.IsTeamAttribute(attributeName) then
				RequestRelationStateRefresh(
					"Equipe do jogador alterada"
				)
			end
		end)
	record.CharacterConnections[
		#record.CharacterConnections + 1
	] = relationAttributeConnection

	syncVisuals(character)
end

local function SetupPlayer(player)
	if player == S.LocalPlayer then
		return
	end

	PlayerCache.Disconnect(
		player
	)

	local record =
		PlayerCache.Get(player)

	local charAdded =
		player.CharacterAdded:
		Connect(function(character)
			if not Runtime.Alive then
				return
			end

			ESP.Clear(record)

			if State.CurrentTarget == player then
				Aim.ClearCurrentTarget("Jogador renasceu")
			end

			PlayerCache.BindCharacter(
				player,
				character
			)

			BindImmediateESPCharacterEvents(
				player,
				record
			)

			RequestPlayerListRefresh()
		end)

	local charRemoving =
		player.CharacterRemoving:
		Connect(function(character)
			if record.Character == character then
				ESP.Clear(record)
				PlayerCache.ClearCharacter(record)

				if State.CurrentTarget == player then
					Aim.ClearCurrentTarget(
						"Personagem removido"
					)
				end

				RequestPlayerListRefresh()
			end
		end)

	local function relationChanged()
		if Runtime.Alive and player.Parent == S.Players then
			RequestRelationStateRefresh(
				"Relação de equipe alterada"
			)
		end
	end

	local teamConn =
		player:GetPropertyChangedSignal("Team"):
		Connect(relationChanged)

	local teamColorConn =
		player:GetPropertyChangedSignal("TeamColor"):
		Connect(relationChanged)

	local neutralConn =
		player:GetPropertyChangedSignal("Neutral"):
		Connect(relationChanged)

	local teamAttributeConn =
		player.AttributeChanged:
		Connect(function(attributeName)
			if Universal.IsTeamAttribute(attributeName) then
				relationChanged()
			end
		end)

	record.Connections = {
		charAdded,
		charRemoving,
		teamConn,
		teamColorConn,
		neutralConn,
		teamAttributeConn,
	}

	local character = player.Character

	if character and character.Parent then
		PlayerCache.BindCharacter(
			player,
			character
		)

		BindImmediateESPCharacterEvents(
			player,
			record
		)
	else
		ESP.SafeRefresh(player)
	end
end

--==============================================================
-- LOOPS
--==============================================================

function Aim.UpdateTarget()
	if not Config.AimEnabled or not S.Camera or not Util.LocalCharacterAlive() then
		Aim.ClearCurrentTarget()
		return
	end
	local candidate = Aim.AcquireTarget()
	if candidate then
		TargetSwipe.Assign(candidate)
	elseif not (Config.StickyTarget and Aim.CurrentTargetGraceValid()) then
		Aim.ClearCurrentTarget(Config.WallCheck and "Alvo escondido por uma parede" or "Alvo perdido")
	end
end

local function StartLoops()
	task.spawn(function()
		while Runtime.Alive
			and State.UI.Root
			and State.UI.Root.Parent do

			local iterationOk, iterationError = pcall(function()
				UI.EnsureAimActivation()

				S.Camera =
					S.Workspace.CurrentCamera

				Aim.UpdateTarget()
			end)

			if not iterationOk then
				State.AimScanRecoveries += 1
				State.LastRuntimeError = string.sub(
					tostring(iterationError),
					1,
					240
				)
				State.Debug.LastReason =
					"Busca reiniciada automaticamente"

				pcall(function()
					Aim.ClearCurrentTarget(
						"Busca reiniciada automaticamente"
					)
				end)
			end

			local scanInterval = Persistence.FiniteNumber(
				Config.TargetScanInterval,
				0.025
			)

			if scanInterval <= 0 then
				scanInterval = 0.025
			end

			task.wait(
				math.max(
					scanInterval,
					1 / 240
				)
			)
		end
	end)

	task.spawn(function()
		local nextLabelUpdate = 0
		local nextESPRecovery = 0

		while Runtime.Alive
			and State.UI.Root
			and State.UI.Root.Parent do

			local iterationOk, iterationError = pcall(function()
			S.Camera = S.Workspace.CurrentCamera
			local now = os.clock()

			if now >= nextESPRecovery then
				nextESPRecovery =
					now
					+
					math.max(
						Persistence.FiniteNumber(
							Config.ESPRecoveryInterval,
							0.75
						),
						0.25
					)

				for _, player in ipairs(S.Players:GetPlayers()) do
					if player ~= S.LocalPlayer then
						local record = PlayerCache.Get(player)
						local character = player.Character

						if character ~= record.Character then
							ESP.Clear(record)

							if character and character.Parent then
								PlayerCache.BindCharacter(player, character)
								BindImmediateESPCharacterEvents(player, record)
							else
								PlayerCache.ClearCharacter(record)
							end
						elseif character
							and character.Parent
							and not PlayerCache.PartBelongsToRecord(
								record,
								record.Root
							) then

							PlayerCache.RefreshBodyParts(record)

							if record.OnPartsRefreshed then
								record.OnPartsRefreshed(character)
							end
						end

						ESP.SafeRefresh(player)
					end
				end
			end

			if now >= nextLabelUpdate
				and Config.ESPLabels
				and S.Camera then

				nextLabelUpdate =
					now
					+
					math.max(
						Persistence.FiniteNumber(
							Config.LabelUpdateInterval,
							1 / 60
						),
						1 / 60
					)

				for player, record in pairs(
					State.Records
				) do

					if player.Parent == S.Players
						and record.LabelText then

						ESP.UpdateLabel(record)
					end
				end
			end

			end)

			if not iterationOk then
				State.ESPRecoveries += 1
				State.LastRuntimeError = string.sub(
					tostring(iterationError),
					1,
					240
				)
			end

			task.wait(1 / 60)
		end
	end)

end

local function StartRender()
	pcall(function()
		S.RunService:UnbindFromRenderStep(
			Runtime.RenderStepName
		)
	end)

	local renderPriority =
		Runtime.GetRenderPriority()

	Runtime.ActiveRenderPriority =
		renderPriority

	S.RunService:
		BindToRenderStep(
			Runtime.RenderStepName,
			renderPriority,
			function(deltaTime)
				if not Runtime.Alive
					or not State.UI.Root
					or not State.UI.Root.Parent then

					return
				end

				local renderOk, renderError = pcall(function()

				local expectedPriority =
					Runtime.GetRenderPriority()

				if expectedPriority
					~= Runtime.ActiveRenderPriority then

					Runtime.ActiveRenderPriority =
						expectedPriority

					task.defer(function()
						if Runtime.Alive then
							StartRender()
						end
					end)

					return
				end

				S.Camera =
					S.Workspace.CurrentCamera

				if not S.Camera then
					return
				end

				local instantFPS = 1 / math.max(deltaTime, 1 / 240)
				State.SmoothedFPS =
					State.SmoothedFPS + (instantFPS - State.SmoothedFPS) * 0.08

				local now = os.clock()
				if now - State.LastStatsUpdate >= 0.50 then
					State.LastStatsUpdate = now
					if State.UI.FPSLabel then
						State.UI.FPSLabel.Text =
							"FPS: " .. tostring(math.floor(State.SmoothedFPS + 0.5))
					end

					if State.UI.PingLabel then
						local ok, ping = pcall(function()
							local item = S.Stats.Network.ServerStatsItem["Data Ping"]
							local value = item:GetValue()
							if type(value) == "number" then
								return value
							end
							local raw = tostring(item:GetValueString() or "")
								return tonumber(string.match(raw, "[%d%.]+"))
							end)
							local validPing = ok
								and Persistence.FiniteNumber(ping, nil)
							State.UI.PingLabel.Text =
								validPing
								and ("PING: " .. tostring(math.floor(validPing + 0.5)) .. " ms")
								or "PING: --"
					end
				end

				local viewportSize = S.Camera.ViewportSize

				if State.LastViewportSize ~= viewportSize then
					State.LastViewportSize = viewportSize
					UI.ClampMovableToViewport()
				end

				UI.UpdateDebugLine(nil)

				if State.UI.CompactSub then
					State.UI.CompactSub.Text =
						State.UI.Status.Text
				end

				State.UI.FOV.Position =
					UDim2.fromScale(
						0.5,
						0.5
					)

				local effectiveFOV =
					Aim.EffectiveFOV()

				if State.LastRenderedFOV ~= effectiveFOV then
					State.LastRenderedFOV =
						effectiveFOV

					State.UI.FOV.Size =
						UDim2.fromOffset(
							effectiveFOV * 2,
							effectiveFOV * 2
						)
				end

				State.UI.FOV.Visible =
					Config.FOVEnabled
					and Config.ShowFOVCircle

				State.UI.DebugOverlay.Visible =
					Config.DebugEnabled

				if Config.DebugEnabled then
					local debugRegion = State.Debug.LastRegion
					local debugRegionLabel = debugRegion
						and BodyRegions[debugRegion]
						and BodyRegions[debugRegion].Label
						or debugRegion
						or "-"
					State.UI.DebugText.Text =
						"Estado: "
						.. tostring(State.Debug.LastReason)
						.. "\nCandidatos: "
						.. tostring(State.Debug.Candidates)
						.. "\nRegião: "
						.. tostring(debugRegionLabel)
						.. "\nPontuação: "
						.. (
							State.Debug.LastScore
							and string.format(
								"%.2f",
								tonumber(State.Debug.LastScore) or 0
							)
							or "-"
						)
						.. "\nDistância: "
						.. (
							State.Debug.LastDistance
							and (
								tostring(
									math.floor(State.Debug.LastDistance + 0.5)
								)
								.. " studs"
							)
							or "-"
						)
						.. "\nRecuperações: "
						.. tostring(
							State.AimScanRecoveries
							+ State.ESPRecoveries
							+ State.RenderRecoveries
						)
						.. "\nÚltimo erro: "
						.. tostring(State.LastRuntimeError or "-")
				end

				UI.EnsureAimActivation()

				if not Config.AimEnabled then
					State.UI.Status.Text =
						"Mira desativada"

					State.UI.StatusDot.BackgroundColor3 =
						Theme.Muted

					State.UI.StatusMini.Text =
						"DESATIVADA"

					State.UI.StatusMini.TextColor3 =
						Theme.Sub

					UI.SetFOVStateColor(Theme.Text)

					State.UI.DebugLine.Visible =
						false

					return
				end

				State.UI.StatusDot.BackgroundColor3 =
					Theme.Success

				if not Util.LocalCharacterAlive() then
					State.UI.Status.Text = "Aguardando seu personagem"
					State.UI.StatusMini.Text = "AGUARDE"
					State.UI.StatusMini.TextColor3 = Theme.Warning
					UI.SetFOVStateColor(Theme.Warning)
					return
				end

				if State.UI.PollWorldGestureInput then
					State.UI.PollWorldGestureInput()
				end
				local swipeRetained, swipeVisible = TargetSwipe.RefreshCurrent()

				local currentRecord =
					State.CurrentTarget
					and State.Records[State.CurrentTarget]

				if State.CurrentTarget
					and State.CurrentTarget.Parent == S.Players
					and State.CurrentPart
					and State.CurrentPart.Parent
					and PlayerCache.IsAlive(currentRecord)
					and PlayerCache.PartBelongsToRecord(
						currentRecord,
						State.CurrentPart
					) then

					if Config.WallCheck
						and Config.RenderWallValidation
						and (swipeVisible == false
							or (swipeVisible == nil and not Aim.CurrentPointVisible())) then

						local mobileKeepsTarget =
							swipeRetained

						if mobileKeepsTarget
							and (State.Swipe.Transition ~= nil) then

							TargetSwipe.CancelTransition()
						end

						if not mobileKeepsTarget then
							Aim.ClearCurrentTarget(
								"Alvo oculto / parede"
							)
						end

						State.UI.Status.Text =
							mobileKeepsTarget
							and "Parede detectada • alvo mantido"
							or "Parede detectada • procurando outro alvo"

						State.UI.StatusMini.Text =
							"PAREDE"

						State.UI.StatusMini.TextColor3 =
							Theme.Danger

						UI.SetFOVStateColor(Theme.Danger)

						return
					end

					State.UI.Status.Text =
						"Alvo: "
						..
						State.CurrentTarget.DisplayName
						..
						(
							State.CurrentRegion
							and (
									" • "
								..
								(
									BodyRegions[
										State.CurrentRegion
									]
									and
									BodyRegions[
										State.CurrentRegion
									].Label
									or State.CurrentRegion
								)
							)
							or ""
						)

					State.UI.StatusMini.Text =
						"ALVO"

					State.UI.StatusMini.TextColor3 =
						Theme.Success

					UI.SetFOVStateColor(Theme.Success)

					if Config.DebugEnabled
						and Config.DebugShowTargetLine then

						local debugPoint = Aim.CurrentAimPoint()

						if debugPoint then
							debugPoint = Aim.PredictedPosition(
								State.CurrentPart,
								debugPoint
							)
						end

						UI.UpdateDebugLine(debugPoint)
					end

					Aim.Apply(
						State.CurrentPart,
						deltaTime
					)

				else
					local mobileKeepsTarget =
						swipeRetained

					if mobileKeepsTarget
						and (State.Swipe.Transition ~= nil) then

						TargetSwipe.CancelTransition()
					end

					if State.CurrentTarget and not mobileKeepsTarget then
						Aim.ClearCurrentTarget("Alvo inválido")
					end

					State.UI.Status.Text =
						mobileKeepsTarget
						and "Mantendo o alvo atual"
						or Config.AimMode == "AUTO"
						and "Procurando um alvo"
						or "Nenhum jogador escolhido"

					State.UI.StatusMini.Text =
						mobileKeepsTarget and "MANTENDO" or "BUSCANDO"

					State.UI.StatusMini.TextColor3 =
						Theme.Warning

					UI.SetFOVStateColor(Theme.Danger)
				end
				end)

				if not renderOk then
					State.RenderRecoveries += 1
					State.LastRuntimeError = string.sub(
						tostring(renderError),
						1,
						240
					)
					State.Debug.LastReason =
						"Renderização reiniciada automaticamente"
					pcall(function()
						Aim.ClearCurrentTarget(
							"Renderização reiniciada automaticamente"
						)
					end)
				end
			end
		)

end

function Runtime.Cleanup()
	if Runtime.Cleaned then
		return
	end

	Runtime.Cleaned = true
	Runtime.Alive = false
	if UI.ActiveNumericSlider then UI.ActiveNumericSlider:FinishEditing(false) end
	UI.CloseHelpDialog()
	UI.CloseChoiceMenu()
	Runtime.ActiveRenderPriority = nil
	UI.ActiveSlider = nil
	UI.ActiveSliderInput = nil

	pcall(function()
		S.RunService:UnbindFromRenderStep(
			Runtime.RenderStepName
		)
	end)

	for _, connection in ipairs(Runtime.Connections) do
		Runtime.Disconnect(connection)
	end

	Runtime.Connections = {}

	for player, record in pairs(State.Records) do
		pcall(PlayerCache.Disconnect, player)
		pcall(ESP.Clear, record)
	end

	TargetSwipe.Cancel("Script finalizado")
	Aim.ClearCurrentTarget("Script finalizado")
	State.Records = {}
	State.SelectedPlayers = {}
	State.ManualAllies = {}
	State.ThumbnailCache = {}
	State.ThumbnailPending = {}
end

--==============================================================
-- INITIALIZATION
--==============================================================

BuildVisionRootUI()

Runtime.Track(
	State.UI.CleanupEvent.Event:
	Connect(Runtime.Cleanup)
)

Runtime.Track(
	State.UI.Root.Destroying:
	Connect(Runtime.Cleanup)
)

Runtime.Track(
	State.UI.Root.AncestryChanged:
	Connect(function(_, parent)
		if not parent then
			Runtime.Cleanup()
		end
	end)
)

BuildNavigation()
WireVisionGeneralUI()


for _, player in ipairs(
	S.Players:GetPlayers()
) do
	SetupPlayer(player)
end

UI.WireWorldTapSelection()

Runtime.Track(
	S.Players.PlayerAdded:
	Connect(function(player)
		if not Runtime.Alive then
			return
		end

		SetupPlayer(player)

		RequestPlayerListRefresh()
	end)
)

Runtime.Track(
	S.Players.PlayerRemoving:
	Connect(function(player)
		local wasSelected = State.SelectedPlayers[player] == true
		State.SelectedPlayers[player] =
			nil
		State.ManualAllies[player] =
			nil

		if wasSelected and Config.AimMode == "SELECTED" then
			Config.AimMode = "AUTO"
		end

		if State.UI.RefreshFilters then
			State.UI.RefreshFilters()
		else
			UI.RefreshTeamSidebar()
		end

		if wasSelected and State.UI.RefreshAimControls then
			State.UI.RefreshAimControls()
		end

		if State.CurrentTarget == player then
			Aim.ClearCurrentTarget(
				"Jogador saiu"
			)
		end

		local record =
			State.Records[player]

		if record then
			PlayerCache.Disconnect(player)
			ESP.Clear(record)
		end

		State.Records[player] =
			nil

		State.ThumbnailCache[player.UserId] = nil
		State.ThumbnailPending[player.UserId] = nil

		RequestPlayerListRefresh()
	end)
)

Runtime.Track(
	S.LocalPlayer.CharacterRemoving:
	Connect(function()
		Aim.ClearCurrentTarget("Seu personagem foi removido")
	end)
)

Runtime.Track(
	S.Teams.ChildAdded:
	Connect(function(child)
		if child:IsA("Team") then
			if State.UI.RefreshTeams then
				State.UI.RefreshTeams()
			end

			ESP.RefreshAll()
		end
	end)
)

Runtime.Track(
	S.Teams.ChildRemoved:
	Connect(function(child)
		if child:IsA("Team") then
			if State.UI.RefreshTeams then
				State.UI.RefreshTeams()
			end

			ESP.RefreshAll()
		end
	end)
)

UI.RefreshQuick()
ESP.RefreshAll()
StartLoops()
StartRender()

print("[Aim Assist Pro V34.3.0 - Configurações redesenhadas] carregado")
