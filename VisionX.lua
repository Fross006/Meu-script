-- V35.1.0 — ESP refeito: contorno normal, modo 2D configurável e nova aba ESP.
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
	-- ESP appearance is independent of aim and target-selection settings.
	ESPRenderMode = "NORMAL",
	ESPColorPreset = "THEME",
	ESPThroughWalls = true,
	ESPMaxDistance = 0,
	ESPFillOpacity = 14,
	ESPOutlineOpacity = 100,
	ESPLabelNames = true,
	ESPLabelDistance = true,
	ESPLabelTeam = false,
	ESPNameMode = "DISPLAY",
	ESPTextSize = 12,
	ESP2DBox = true,
	ESP2DStyle = "FULL",
	ESP2DThickness = 1,
	ESP2DOutline = true,
	ESP2DOpacity = 100,
	ESP2DFillOpacity = 0,
	ESP2DPadding = 2,
	ESP2DHealth = true,
	ESP2DHealthText = false,
	ESP2DHealthSide = "LEFT",
	ESP2DTracers = false,
	ESP2DTracerOrigin = "BOTTOM",


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

	local espRanges = {
		ESPMaxDistance={0,20000}, ESPFillOpacity={0,100}, ESPOutlineOpacity={0,100},
		ESPTextSize={9,20}, ESP2DThickness={1,4}, ESP2DOpacity={10,100},
		ESP2DFillOpacity={0,60}, ESP2DPadding={0,12},
	}
	for key,bounds in pairs(espRanges) do
		Config[key]=math.clamp(math.floor(Persistence.FiniteNumber(Config[key],Persistence.DefaultConfig[key])+.5),bounds[1],bounds[2])
	end
	local espChoices = {
		ESPRenderMode={NORMAL=true,["2D"]=true,BOTH=true},
		ESPColorPreset={THEME=true,RED=true,WHITE=true,CYAN=true,GREEN=true,PURPLE=true,YELLOW=true},
		ESPNameMode={DISPLAY=true,USERNAME=true}, ESP2DStyle={FULL=true,CORNERS=true},
		ESP2DHealthSide={LEFT=true,RIGHT=true}, ESP2DTracerOrigin={BOTTOM=true,CENTER=true},
	}
	for key,choices in pairs(espChoices) do
		if type(Config[key])~="string" or not choices[Config[key]] then Config[key]=Persistence.DefaultConfig[key] end
	end
	for _,key in ipairs({"ESPEnabled","GlobalESP","ESPEnemies","ESPAllies","ESPUseTeamColors","SelectedESP","ESPLabels",
		"ESPThroughWalls","ESPLabelNames","ESPLabelDistance","ESPLabelTeam","ESP2DBox","ESP2DOutline","ESP2DHealth","ESP2DHealthText","ESP2DTracers"}) do
		if type(Config[key])~="boolean" then Config[key]=Persistence.DefaultConfig[key] end
	end

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

-- The percentage counts finished initialization stages, never elapsed time.
-- Avatar pictures and the optional body preview retain their live fallbacks.
local Loading = {
	Names = {"Interface", "Mira", "Corpo", "Jogadores", "ESP", "Configurações"},
	Cancelled = {},
	Colors = {
		Panel = Color3.fromRGB(17, 20, 25), Card = Color3.fromRGB(26, 29, 35),
		Border = Color3.fromRGB(59, 64, 74), Text = Color3.fromRGB(243, 245, 249),
		Sub = Color3.fromRGB(159, 165, 178), Muted = Color3.fromRGB(106, 113, 127),
		Red = Color3.fromRGB(246,  70, 89), DeepRed = Color3.fromRGB(116, 40,  50),
	},
}

function Loading.New(class, properties, parent)
	local object = Instance.new(class)
	if object:IsA("GuiObject") then object.BorderSizePixel = 0 end
	if object:IsA("TextLabel") or object:IsA("TextButton") then
		object.BackgroundTransparency = 1
		object.Font = Enum.Font.Gotham
		object.TextColor3 = Loading.Colors.Text
		object.TextSize = 18
	end
	for key, value in pairs(properties or {}) do object[key] = value end
	object.Parent = parent
	return object
end

function Loading.Round(object, radius)
	return Loading.New("UICorner", {CornerRadius = UDim.new(0, radius)}, object)
end

function Loading.Stroke(object, color, thickness, transparency)
	local stroke = Loading.New("UIStroke", {
		Color = color, Thickness = thickness or 1, Transparency = transparency or 0,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border, LineJoinMode = Enum.LineJoinMode.Round,
	}, object)
	-- Centered borders keep the curve and its round tips on the same radius.
	-- Older clients retain their existing border renderer.
	local centered = pcall(function() stroke.BorderStrokePosition = Enum.BorderStrokePosition.Center end)
	return stroke, centered
end

function Loading.Text(parent, text, x, y, w, h, size, color, bold, centered)
	return Loading.New("TextLabel", {
		Text = text, Position = UDim2.fromOffset(x, y), Size = UDim2.fromOffset(w, h),
		TextSize = size, TextColor3 = color or Loading.Colors.Text,
		Font = bold and Enum.Font.GothamBold or Enum.Font.Gotham,
		TextXAlignment = centered and Enum.TextXAlignment.Center or Enum.TextXAlignment.Left,
	}, parent)
end

function Loading.Line(parent, x1, y1, x2, y2, thickness, color)
	local dx, dy = x2 - x1, y2 - y1
	local line = Loading.New("Frame", {
		AnchorPoint = Vector2.new(.5, .5), Position = UDim2.fromOffset((x1+x2)/2, (y1+y2)/2),
		Size = UDim2.fromOffset(math.sqrt(dx*dx+dy*dy)+thickness, thickness),
		Rotation = math.deg(math.atan2(dy, dx)), BackgroundColor3 = color,
	}, parent)
	Loading.Round(line, 99)
	return line
end

function Loading.Outline(parent, x, y, width, height, radius, color, thickness)
	local shape = Loading.New("Frame", {
		Position = UDim2.fromOffset(x,y), Size = UDim2.fromOffset(width,height),
		BackgroundTransparency = 1,
	}, parent)
	Loading.Round(shape,radius)
	local stroke = Loading.Stroke(shape,color,thickness or 2)
	return shape, stroke
end

function Loading.Arc(parent, diameter, first, last, color, thickness)
	local arc = Loading.New("Frame", {
		Name = "SmoothArc", BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(.5,.5), Position = UDim2.fromScale(.5,.5),
		Size = UDim2.fromOffset(diameter,diameter),
	}, parent)
	local span = math.clamp(last-first,2,358)
	local curve = Loading.New("Frame", {
		Name = "CircularStroke", BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(.5,.5), Position = UDim2.fromScale(.5,.5),
		Size = UDim2.fromScale(1,1), Rotation = first+span/2,
	}, arc)
	Loading.New("UICorner",{CornerRadius = UDim.new(.5,0)},curve)
	local stroke, centered = Loading.Stroke(curve,color,thickness)
	local radius = diameter/2 + (centered and 0 or thickness/2)
	local halfAngle = math.rad(span/2)
	local cutoff = math.clamp(.5+radius*math.cos(halfAngle)/diameter,.001,.999)
	local feather = math.min(.35/diameter,cutoff/2,(1-cutoff)/2)
	-- One native circle, cut by a transparency mask. No polygonal line pieces.
	Loading.New("UIGradient", {
		Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0,1),
			NumberSequenceKeypoint.new(cutoff-feather,1),
			NumberSequenceKeypoint.new(cutoff+feather,0),
			NumberSequenceKeypoint.new(1,0),
		}),
	}, stroke)
	for _, angle in ipairs({-halfAngle,halfAngle}) do
		local tip = Loading.New("Frame", {
			Name = "RoundTip", AnchorPoint = Vector2.new(.5,.5),
			Position = UDim2.fromOffset(diameter/2+math.cos(angle)*radius,diameter/2+math.sin(angle)*radius),
			Size = UDim2.fromOffset(thickness,thickness), BackgroundColor3 = color,
		}, curve)
		Loading.New("UICorner",{CornerRadius = UDim.new(.5,0)},tip)
	end
	return arc
end

function Loading.Icon(parent, index)
	local icon = Loading.New("Frame", {
		Name = "ComponentIcon", BackgroundTransparency = 1,
		Position = UDim2.fromOffset(18,15), Size = UDim2.fromOffset(32,32),
	}, parent)
	local ink, color = {}, Loading.Colors.Text
	local function outline(host,x,y,w,h,radius)
		local shape,stroke = Loading.Outline(host,x,y,w,h,radius,color,2)
		ink[#ink+1] = {stroke,"Color"}
		return shape
	end
	local function circle(x,y,diameter)
		return outline(icon,x,y,diameter,diameter,diameter/2)
	end
	local function line(x1,y1,x2,y2)
		ink[#ink+1] = {Loading.Line(icon,x1,y1,x2,y2,2,color),"BackgroundColor3"}
	end
	local function shoulders(x,y,width,height)
		local clip = Loading.New("Frame", {Name = "Shoulders", BackgroundTransparency = 1,
			Position = UDim2.fromOffset(x,y), Size = UDim2.fromOffset(width,height), ClipsDescendants = true},icon)
		outline(clip,1,1,width-2,height+10,(width-2)/2)
	end
	if index == 1 then
		-- A rounded window with a sidebar and two content rows.
		outline(icon,3,5,26,23,4)
		line(4,12,28,12); line(13,13,13,27)
		line(18,18,24,18); line(18,23,24,23)
	elseif index == 2 then
		circle(7,7,18)
		line(16,2,16,9); line(16,23,16,30)
		line(2,16,9,16); line(23,16,30,16)
	elseif index == 3 then
		circle(11,3,10)
		shoulders(4,18,24,12)
	elseif index == 4 then
		-- Two complete silhouettes, without intersecting strokes.
		circle(4,6,8); circle(20,6,8)
		shoulders(1,19,14,11); shoulders(17,19,14,11)
	elseif index == 5 then
		-- The almond outline consists of two clipped circular curves.
		local top = Loading.New("Frame", {Name = "UpperEyelid", BackgroundTransparency = 1,
			Position = UDim2.fromOffset(1,7), Size = UDim2.fromOffset(30,9), ClipsDescendants = true},icon)
		local bottom = Loading.New("Frame", {Name = "LowerEyelid", BackgroundTransparency = 1,
			Position = UDim2.fromOffset(1,16), Size = UDim2.fromOffset(30,9), ClipsDescendants = true},icon)
		outline(top,-1.25,1,32.5,32.5,16.25)
		outline(bottom,-1.25,-24.5,32.5,32.5,16.25)
		circle(12,12,8)
	else
		-- Recognizable settings sliders, with clear gaps around the handles.
		line(6,3,6,9); line(6,15,6,29); circle(3,9,6)
		line(16,3,16,18); line(16,24,16,29); circle(13,18,6)
		line(26,3,26,5); line(26,11,26,29); circle(23,5,6)
	end
	return icon,ink
end

function Loading.Alpha(session, object, property, value)
	local base = session.OpacityMap[object]
	if base then base[property] = value end
	object[property] = 1 - (1-value)*session.Opacity
end

function Loading.PaintRow(session, index, status)
	local row, colors = session.Rows[index], Loading.Colors
	row.State = status
	local active, done, failed = status == "loading", status == "done", status == "failed"
	row.Status.Text = failed and "Falhou" or active and "Carregando" or "Aguardando"
	row.Status.Visible = not done
	row.Status.TextColor3 = failed and colors.Red or active and colors.Sub or colors.Muted
	row.Indicator.Position = UDim2.new(1, done and -44 or -150, .5, -12)
	row.Check.Visible = done
	row.Spinner.Visible = active
	row.Ring.Visible = not done
	row.RingStroke.Color = failed and colors.Red or colors.Border
	row.Stroke.Color = (active or failed) and colors.Red or colors.Border
	Loading.Alpha(session, row.Stroke, "Transparency", (active or failed) and .36 or .60)
	for _, entry in ipairs(row.Ink) do entry[1][entry[2]] = active and colors.Red or colors.Text end
end

function Loading.Layout(session)
	local viewport = session.Root.AbsoluteSize
	if viewport.X < 2 or viewport.Y < 2 then
		local camera = S.Workspace.CurrentCamera
		viewport = camera and camera.ViewportSize or Vector2.new(960, 540)
	end
	local portrait = viewport.X < viewport.Y*1.15
	local width, height = portrait and 520 or 1040, portrait and 844 or 554
	session.Panel.Size = UDim2.fromOffset(width, height)
	session.Scale.Scale = math.min((viewport.X-32)/width, (viewport.Y-32)/height, 1.12)
	session.Scale.Scale = math.max(.1, session.Scale.Scale)
	session.Left.Size = UDim2.fromOffset(portrait and 520 or 580, portrait and 392 or 554)
	session.Right.Position = UDim2.fromOffset(portrait and 24 or 614, portrait and 406 or 38)
	session.Right.Size = UDim2.fromOffset(portrait and 472 or 394, portrait and 420 or 478)
	session.Divider.Position = UDim2.fromOffset(portrait and 24 or 582, portrait and 391 or 24)
	session.Divider.Size = UDim2.fromOffset(portrait and 472 or 1, portrait and 1 or 506)
	session.Logo.Position = UDim2.new(.5, 0, 0, portrait and 90 or 130)
	session.LogoScale.Scale = portrait and .75 or 1
	session.Wordmark.Position = UDim2.new(.5, 0, 0, portrait and 157 or 224)
	session.Version.Position = UDim2.new(.5, 0, 0, portrait and 197 or 268)
	session.Welcome.Position = UDim2.fromOffset(28, portrait and 234 or 316)
	session.Welcome.Size = UDim2.new(1, -56, 0,  50)
	session.Welcome.TextSize = portrait and 32 or 36
	session.Subtitle.Position = UDim2.fromOffset(28, portrait and 282 or 370)
	session.Subtitle.Size = UDim2.new(1, -56, 0, 28)
	session.ProgressBox.Position = UDim2.new(0,  40, 0, portrait and 318 or 438)
	session.ProgressBox.Size = UDim2.new(1, -80, 0,  50)
	session.Footer.Position = UDim2.fromOffset(24, portrait and 371 or 500)
	session.Footer.Size = UDim2.new(1, -48, 0, 26)
	session.RightTitle.Size = UDim2.new(1, 0, 0, 36)
	session.RightTitle.TextSize = portrait and 24 or 25
	for i, row in ipairs(session.Rows) do
		local rowHeight = portrait and 56 or 62
		row.Card.Position = UDim2.fromOffset(0, (portrait and 44 or 58)+(i-1)*(portrait and 64 or  70))
		row.Card.Size = UDim2.new(1, 0, 0, rowHeight)
		row.Icon.Position = UDim2.new(0, 18, .5, -16)
	end
	session.Close.Position = UDim2.new(.5, -80, 1, -44)
	Loading.PaintOpacity(session)
end

function Loading.PaintOpacity(session)
	for object, properties in pairs(session.OpacityMap) do
		if object.Parent then
			for property, base in pairs(properties) do object[property] = 1-(1-base)*session.Opacity end
		end
	end
	session.Backdrop.BackgroundTransparency = 1-.48*session.Opacity
	session.Panel.Position = UDim2.new(.5, 0, .5, (1-session.Opacity)*10)
	if session.Blur then session.Blur.Size = 12*session.Opacity end
end

function Loading.Destroy()
	local session = Loading.Session
	if not session then return end
	Loading.Session = nil
	session.Destroyed = true
	for _, connection in ipairs(session.Connections) do connection:Disconnect() end
	session.Connections = {}
	if session.Blur then session.Blur:Destroy(); session.Blur = nil end
	if session.Root then session.Root:Destroy() end
	session.OnReady = nil
end

function Loading.Cancel()
	Loading.Destroy()
	Runtime.Cleanup()
	if State.UI.Root then State.UI.Root:Destroy() end
end

function Loading.Tick(session, dt)
	if session ~= Loading.Session or session.Destroyed then return end
	dt = math.clamp(dt, 0, .1)
	session.Time += dt
	if session.Phase ~= "failed" then
		session.Arc.Rotation = (session.Time*120)%360
		for _, row in ipairs(session.Rows) do
			if row.State == "loading" then row.Spinner.Rotation = (session.Time*240)%360 end
		end
	end
	session.ProgressTime = math.min(session.ProgressTime+dt, .18)
	local p = 1-(1-session.ProgressTime/.18)^3
	session.DisplayProgress = session.ProgressFrom+(session.Progress-session.ProgressFrom)*p
	session.Fill.Size = UDim2.fromScale(session.DisplayProgress, 1)
	if session.Phase == "leaving" then
		session.ExitTime += dt
		session.Opacity = 1-math.sin(math.min(session.ExitTime/.26, 1)*math.pi/2)
		Loading.PaintOpacity(session)
		if session.ExitTime >= .26 then Loading.Destroy() end
		return
	end
	local opacity = 1-(1-math.min(session.Time/.28, 1))^4
	if opacity ~= session.Opacity then session.Opacity = opacity; Loading.PaintOpacity(session) end
	if session.Phase == "ready" and session.ProgressTime >= .18 and session.Time >= .28 then
		session.Phase, session.ExitTime = "leaving", 0
		local ready = session.OnReady
		session.OnReady = nil
		if ready then
			local ok, problem = pcall(ready)
			if not ok then Loading.HandleError(problem) end
		end
	end
end

function Loading.Create()
	Loading.Destroy()
	local c = Loading.Colors
	local session = {Rows = {}, Connections = {}, OpacityMap = {}, Opacity = 1, Time = 0,
		Phase = "loading", Completed = 0, Progress = 0, DisplayProgress = 0, ProgressFrom = 0, ProgressTime = .18}
	Loading.Session = session
	session.Root = Loading.New("ScreenGui", {Name = "VisionX_Loading", ResetOnSpawn = false,
		IgnoreGuiInset = true, DisplayOrder = 1000001, ZIndexBehavior = Enum.ZIndexBehavior.Sibling}, S.PlayerGui)
	local cleanup = Loading.New("BindableEvent", {Name = "AAP_Cleanup"}, session.Root)
	session.Connections[#session.Connections+1] = cleanup.Event:Connect(Loading.Cancel)
	session.Connections[#session.Connections+1] = session.Root.Destroying:Connect(Loading.Cancel)
	session.Backdrop = Loading.New("TextButton", {Name = "InputShield", Text = "", AutoButtonColor = false,
		Active = true, Selectable = false, Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = Color3.new(0,0,0), BackgroundTransparency = 1}, session.Root)
	session.Panel = Loading.New("Frame", {Name = "WelcomePanel", AnchorPoint = Vector2.new(.5,.5),
		Position = UDim2.fromScale(.5,.5), BackgroundColor3 = c.Panel, BackgroundTransparency = .035,
		Active = true, ZIndex = 2}, session.Root)
	Loading.Round(session.Panel, 30)
	Loading.Stroke(session.Panel, c.Red, 1, .52)
	Loading.New("UIGradient", {Color = ColorSequence.new(Color3.new(1,1,1), Color3.fromRGB(175,185,205)), Rotation = 110}, session.Panel)
	session.Scale = Loading.New("UIScale", {}, session.Panel)
	session.Left = Loading.New("Frame", {BackgroundTransparency = 1}, session.Panel)
	session.Right = Loading.New("Frame", {BackgroundTransparency = 1}, session.Panel)
	session.Divider = Loading.New("Frame", {BackgroundColor3 = c.Border, BackgroundTransparency = .65}, session.Panel)
	session.Logo = Loading.New("Frame", {Name = "VisionXLogo", BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(.5,.5), Size = UDim2.fromOffset(180,180)}, session.Left)
	session.LogoScale = Loading.New("UIScale", {}, session.Logo)
	local track = Loading.New("Frame", {AnchorPoint = Vector2.new(.5,.5), Position = UDim2.fromScale(.5,.5),
		Size = UDim2.fromOffset(180,180), BackgroundTransparency = 1}, session.Logo)
	Loading.Round(track, 999); Loading.Stroke(track, c.Border, 4, .28)
	session.Arc = Loading.Arc(session.Logo, 180, -86, 10, c.Red, 4)
	local mark = Loading.New("Frame", {Name = "Mark", AnchorPoint = Vector2.new(.5,.5),
		Position = UDim2.fromScale(.5,.5), Size = UDim2.fromOffset(108,108), BackgroundColor3 = c.Card}, session.Logo)
	Loading.Round(mark, 23); Loading.Stroke(mark, c.Sub, 1.5, .56)
	Loading.New("UIGradient", {Color = ColorSequence.new(Color3.new(1,1,1), Color3.fromRGB(160,170,185)), Rotation = 90}, mark)
	local v = Loading.Text(mark, "V", 0, 0, 108, 108,  70, c.Red, true, true)
	v.Font = Enum.Font.GothamBlack
	Loading.New("UIGradient", {Color = ColorSequence.new(Color3.new(1,1,1), Color3.fromRGB(158,62, 70)), Rotation = 90}, v)
	session.Wordmark = Loading.Text(session.Left, 'VISION<font color="#F64659">X</font>', 0, 0, 300,  40, 30, c.Text, true, true)
	session.Wordmark.RichText = true; session.Wordmark.Font = Enum.Font.GothamBlack; session.Wordmark.AnchorPoint = Vector2.new(.5,0)
	session.Version = Loading.New("Frame", {AnchorPoint = Vector2.new(.5,0), Size = UDim2.fromOffset( 70,30), BackgroundColor3 = c.Card}, session.Left)
	Loading.Round(session.Version, 99); Loading.Stroke(session.Version,c.Border,1,.45)
	Loading.Text(session.Version,"V35",0,0, 70,30,18,c.Red,true,true)
	session.Welcome = Loading.Text(session.Left,"Bem-vindo ao VisionX.",0,0,0,50,36,c.Text,true,true)
	session.Subtitle = Loading.Text(session.Left,"Estamos preparando seu menu.",0,0,0,28,20,c.Sub,false,true)
	session.ProgressBox = Loading.New("Frame", {BackgroundTransparency = 1}, session.Left)
	session.Current = Loading.Text(session.ProgressBox,"Preparando interface…",0,0,400,26,18)
	session.Current.Size = UDim2.new(1,-60,0,26)
	session.Percent = Loading.Text(session.ProgressBox,"0%",0,0,60,26,18,c.Text,false,false)
	session.Percent.Position = UDim2.new(1,-60,0,0); session.Percent.TextXAlignment = Enum.TextXAlignment.Right
	local bar = Loading.New("Frame", {Name = "ProgressTrack", Position = UDim2.fromOffset(0,32),
		Size = UDim2.new(1,0,0,18), BackgroundColor3 = c.Border, BackgroundTransparency = .22}, session.ProgressBox)
	Loading.Round(bar,99); Loading.Stroke(bar,c.Muted,1,.7)
	session.Fill = Loading.New("Frame", {Name = "ProgressFill", Size = UDim2.fromScale(0,1), BackgroundColor3 = Color3.new(1,1,1)}, bar)
	Loading.Round(session.Fill,99)
	Loading.New("UIGradient", {Color = ColorSequence.new(Color3.fromRGB(255,101,110),c.Red), Rotation = 90}, session.Fill)
	session.Footer = Loading.Text(session.Left,"O menu abre quando tudo estiver pronto.",0,0,0,26,16,c.Sub,false,true)
	session.RightTitle = Loading.Text(session.Right,"Preparando componentes",0,0,0,36,25,c.Text,true)
	for index, name in ipairs(Loading.Names) do
		local row = {}
		row.Card = Loading.New("Frame", {Name = name, BackgroundColor3 = c.Card, BackgroundTransparency = .2}, session.Right)
		Loading.Round(row.Card,16); row.Stroke = Loading.Stroke(row.Card,c.Border,1,.6)
		row.Icon, row.Ink = Loading.Icon(row.Card,index)
		row.Label = Loading.Text(row.Card,name,68,0,0,62,18)
		row.Label.Size = UDim2.new(1,-226,1,0)
		row.Status = Loading.Text(row.Card,"Aguardando",0,0,100,62,14,c.Muted)
		row.Status.Position = UDim2.new(1,-116,0,0); row.Status.Size = UDim2.new(0,102,1,0)
		row.Indicator = Loading.New("Frame", {BackgroundTransparency = 1, Size = UDim2.fromOffset(24,24)}, row.Card)
		row.Ring = Loading.New("Frame", {BackgroundTransparency = 1, Size = UDim2.fromScale(1,1)}, row.Indicator)
		Loading.Round(row.Ring,99); row.RingStroke = Loading.Stroke(row.Ring,c.Border,2)
		row.Spinner = Loading.Arc(row.Indicator,24,-80,150,c.Red,2)
		row.Check = Loading.New("Frame", {Size = UDim2.fromScale(1,1), BackgroundColor3 = c.Text}, row.Indicator)
		Loading.Round(row.Check,99)
		Loading.Text(row.Check,"✓",0,0,24,24,17,c.Panel,true,true)
		session.Rows[index] = row
		Loading.PaintRow(session,index,"waiting")
	end
	session.Close = Loading.New("TextButton", {Text = "Fechar", Size = UDim2.fromOffset(160,32),
		BackgroundTransparency = 0, BackgroundColor3 = c.DeepRed, AutoButtonColor = false, TextSize = 18, Visible = false}, session.Left)
	Loading.Round(session.Close,12)
	session.Connections[#session.Connections+1] = session.Close.Activated:Connect(Loading.Cancel)
	-- One temporary blur, owned by this session. Existing game effects are untouched.
	pcall(function()
		session.Blur = Loading.New("BlurEffect", {Name = "VisionX_LoadingBlur", Size = 0}, game:GetService("Lighting"))
	end)
	for _, object in ipairs(session.Panel:GetDescendants()) do
		local properties = {}
		if object:IsA("GuiObject") then
			properties.BackgroundTransparency = object.BackgroundTransparency
			if object:IsA("TextLabel") or object:IsA("TextButton") then properties.TextTransparency = object.TextTransparency end
		elseif object:IsA("UIStroke") then properties.Transparency = object.Transparency end
		if next(properties) then session.OpacityMap[object] = properties end
	end
	session.OpacityMap[session.Panel] = {BackgroundTransparency = .035}
	session.Opacity = 0
	Loading.Layout(session)
	session.Connections[#session.Connections+1] = session.Root:GetPropertyChangedSignal("AbsoluteSize"):Connect(function() Loading.Layout(session) end)
	session.RenderConnection = S.RunService.RenderStepped:Connect(function(dt) Loading.Tick(session,dt) end)
	session.Connections[#session.Connections+1] = session.RenderConnection
	session.Built = true
	return session
end

function Loading.Yield()
	local session = Loading.Session
	S.RunService.Heartbeat:Wait() -- Give Roblox a frame to paint the actual current stage.
	if not Runtime.Alive or not session or session ~= Loading.Session or session.Destroyed then
		error(Loading.Cancelled,0)
	end
end

function Loading.Stage(index, work)
	local session = Loading.Session
	assert(session and index == session.Completed+1, "Etapa de inicialização fora de ordem")
	session.Active = index
	session.Current.Text = "Carregando " .. Loading.Names[index] .. "…"
	Loading.PaintRow(session,index,"loading")
	Loading.Yield()
	work()
	if not Runtime.Alive or session ~= Loading.Session then error(Loading.Cancelled,0) end
	session.Completed = index
	session.ProgressFrom, session.ProgressTime = session.DisplayProgress, 0
	session.Progress = index/#Loading.Names
	session.Percent.Text = string.format("%d%%", math.floor(session.Progress*100+.5))
	Loading.PaintRow(session,index,"done")
end

function Loading.Finish(onReady)
	local session = Loading.Session
	assert(session and session.Completed == #Loading.Names, "Inicialização incompleta")
	session.Current.Text = "Tudo pronto!"
	session.Subtitle.Text = "Seu menu está pronto."
	session.Phase, session.OnReady = "ready", onReady
end

function Loading.HandleError(problem)
	local session = Loading.Session
	-- Keep the error card while stopping every partially initialized component.
	Loading.Session = nil
	pcall(Runtime.Cleanup)
	if State.UI.Root then pcall(function() State.UI.Root:Destroy() end) end
	Loading.Session = session
	warn("[VisionX V35] Falha na inicialização: " .. tostring(problem))
	if not session or not session.Root or not session.Root.Parent or not session.Built then Loading.Destroy(); return end
	session.Phase, session.OnReady = "failed", nil
	session.Opacity, session.Time = 1, math.max(session.Time,.28)
	session.Welcome.Text = "Não foi possível abrir."
	session.Welcome.TextSize = 30
	session.Subtitle.Text = "Feche esta tela e execute o script novamente."
	session.Subtitle.TextSize = 16
	session.Current.Text = "Falha em " .. Loading.Names[session.Active or 1]
	session.Footer.Visible = false; session.Close.Visible = true
	session.Fill.Parent.Visible = false
	if session.RenderConnection then session.RenderConnection:Disconnect() end
	Loading.PaintRow(session,session.Active or 1,"failed")
	Loading.PaintOpacity(session)
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

-- One transition per object; replacement starts from the current visual state.
Util.TweenJobs = setmetatable({}, {__mode = "k"})

function Util.StopTween(object, finish)
	local job = Util.TweenJobs[object]
	if not job then return end
	Util.TweenJobs[object] = nil
	job.Completed:Disconnect()
	job.Destroying:Disconnect()
	job.Tween:Cancel()
	if finish and object.Parent then
		for property, value in pairs(job.Goal) do object[property] = value end
	end
	job.Tween:Destroy()
end

function Util.Tween(object, properties, duration, style, direction, onFinished)
	if not object or not object.Parent or not Runtime.Alive then return nil end
	local previous = Util.TweenJobs[object]
	if previous and not onFinished then
		local same = true
		for key, value in pairs(properties) do
			if previous.Goal[key] ~= value then same = false; break end
		end
		for key in pairs(previous.Goal) do
			if properties[key] == nil then same = false; break end
		end
		if same then return previous.Tween end
	end
	Util.StopTween(object)
	local unchanged = true
	for key, value in pairs(properties) do
		if object[key] ~= value then unchanged = false; break end
	end
	if unchanged then
		if onFinished then onFinished() end
		return nil
	end
	local tween = S.TweenService:Create(object, TweenInfo.new(
		duration or 0.16, style or Enum.EasingStyle.Cubic,
		direction or Enum.EasingDirection.Out), properties)
	local job = {Tween = tween, Goal = table.clone(properties)}
	Util.TweenJobs[object] = job
	job.Destroying = object.Destroying:Connect(function() Util.StopTween(object) end)
	job.Completed = tween.Completed:Connect(function(playbackState)
		if Util.TweenJobs[object] ~= job then return end
		Util.TweenJobs[object] = nil
		job.Completed:Disconnect()
		job.Destroying:Disconnect()
		task.defer(function() tween:Destroy() end)
		if playbackState == Enum.PlaybackState.Completed and Runtime.Alive and object.Parent then
			if onFinished then onFinished() end
		end
	end)
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
		ESPRefreshing = false,
		Overlay = nil,
		ESPBounds = nil,
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

	record.Humanoid, record.Head, record.Torso, record.Root = nil, nil, nil, nil
	record.BodyParts = {}
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


	local ancestry = character.AncestryChanged:Connect(function()
		if record.Character ~= character or not Runtime.Alive then return end
		if character:IsDescendantOf(S.Workspace) then
			PlayerCache.SchedulePartRefresh(record)
		elseif record.OnPartsRefreshed then
			-- Keep listeners while the same model is temporarily unparented.
			-- The owner clears them on CharacterRemoving or a real replacement.
			record.OnPartsRefreshed(character)
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

local ESP = {
	RenderName = "VisionX_ESP_Render",
	LastRecovery = 0,
	Colors = {
		RED = Color3.fromRGB(244, 66, 94), WHITE = Color3.fromRGB(240, 243, 250),
		CYAN = Color3.fromRGB(66, 207, 240), GREEN = Color3.fromRGB(83, 222, 146),
		PURPLE = Color3.fromRGB(179, 132, 247), YELLOW = Color3.fromRGB(248, 205, 87),
	},
	Edges = {{1,2},{1,3},{1,5},{2,4},{2,6},{3,4},{3,7},{4,8},{5,6},{5,7},{6,8},{7,8}},
}

function ESP.RecordError(problem)
	State.ESPRecoveries += 1
	State.LastRuntimeError = string.sub(tostring(problem), 1, 240)
end

function ESP.SelectedAllowed(player)
	return Config.ESPEnabled and Config.SelectedESP and player ~= S.LocalPlayer
		and State.SelectedPlayers[player] == true
end

function ESP.ShouldShow(player)
	return player ~= S.LocalPlayer and player.Parent == S.Players and Config.ESPEnabled
		and (Config.GlobalESP or ESP.SelectedAllowed(player) or Universal.ESPRelationAllowed(player))
end

function ESP.ColorFor(player)
	if ESP.SelectedAllowed(player) then return Theme.Accent2 end
	if Config.ESPUseTeamColors then return Util.TeamColor(player) end
	return ESP.Colors[Config.ESPColorPreset] or Theme.Accent
end

function ESP.UsesNormal()
	return Config.ESPRenderMode ~= "2D"
end

function ESP.Uses2D()
	return Config.ESPRenderMode == "2D" or Config.ESPRenderMode == "BOTH"
end

function ESP.DestroyField(record, key)
	local object = record[key]
	record[key] = nil
	if object then pcall(function() object:Destroy() end) end
end

function ESP.ClearLabel(record)
	ESP.DestroyField(record, "Label")
	record.LabelText, record.LastLabelText = nil, nil
end

function ESP.Clear2D(record)
	if record.Overlay then
		local root = record.Overlay.Root
		record.Overlay = nil
		pcall(function() root:Destroy() end)
	end
end

function ESP.Clear(record)
	if not record then return end
	ESP.Clear2D(record)
	ESP.ClearLabel(record)
	ESP.DestroyField(record, "Highlight")
	record.ESPBounds, record.ESPRayParams, record.ESPVisible, record.ESPVisibilityAt = nil, nil, nil, nil
end

function ESP.ReconcileRecord(record)
	local player, character = record.Player, record.Player.Character
	if character and not character:IsA("Model") then character = nil end
	local linked = record.OnPartsRefreshed and #record.CharacterConnections >= 3
	if linked then
		for _, connection in ipairs(record.CharacterConnections) do
			if not connection.Connected then linked = false; break end
		end
	end
	if character ~= record.Character or character and not linked then
		ESP.Clear(record)
		PlayerCache.BindCharacter(player, character)
		if character and BindImmediateESPCharacterEvents then BindImmediateESPCharacterEvents(player, record) end
	elseif character and character:IsDescendantOf(S.Workspace) then
		local humanoid = record.Humanoid
		if not PlayerCache.PartBelongsToRecord(record, record.Root)
			or not PlayerCache.PartBelongsToRecord(record, record.Head)
			or humanoid and not humanoid:IsDescendantOf(character)
			or not humanoid and character:FindFirstChildWhichIsA("Humanoid", true) then
			PlayerCache.RefreshBodyParts(record)
			if record.OnPartsRefreshed then record.OnPartsRefreshed(character) end
		end
	end
end

function ESP.Distance(record, camera)
	local root = record.Root
	if not camera or not PlayerCache.PartBelongsToRecord(record, root) then return nil end
	local distance = (root.Position - camera.CFrame.Position).Magnitude
	return distance == distance and distance < math.huge and distance or nil
end

function ESP.InRange(distance)
	return distance ~= nil and (Config.ESPMaxDistance == 0 or distance <= Config.ESPMaxDistance)
end

function ESP.TextFor(record, distance)
	if not Config.ESPLabels then return "" end
	local parts = {}
	if Config.ESPLabelNames then
		parts[#parts + 1] = Config.ESPNameMode == "USERNAME" and ("@" .. record.Player.Name) or record.Player.DisplayName
	end
	if Config.ESPLabelDistance and distance then parts[#parts + 1] = tostring(math.floor(distance + .5)) .. " studs" end
	if Config.ESPLabelTeam then parts[#parts + 1] = Util.TeamName(record.Player) end
	return table.concat(parts, " · ")
end

function ESP.EnsureFolder()
	if not ESP.Folder or ESP.Folder.Parent ~= S.Workspace then
		ESP.DestroyField(ESP, "Folder")
		ESP.Folder = Util.New("Folder", {Name = "VisionX_ESP_Contours"}, S.Workspace)
	end
	return ESP.Folder
end

function ESP.EnsureRoot()
	if not ESP.Root or ESP.Root.Parent ~= S.PlayerGui then
		ESP.DestroyField(ESP, "Root")
		ESP.Root = Util.New("ScreenGui", {Name = "VisionX_ESP_2D", ResetOnSpawn = false,
			IgnoreGuiInset = true, DisplayOrder = 5, ZIndexBehavior = Enum.ZIndexBehavior.Sibling}, S.PlayerGui)
	end
	ESP.Root.Enabled = Config.ESPEnabled and ESP.Uses2D()
	return ESP.Root
end

function ESP.EnsureNormal(record, enabled)
	if not ESP.UsesNormal() then ESP.DestroyField(record, "Highlight"); return end
	local parent = ESP.EnsureFolder()
	if not record.Highlight or record.Highlight.Parent ~= parent then
		ESP.DestroyField(record, "Highlight")
		record.Highlight = Util.New("Highlight", {Name = "Player_" .. record.Player.UserId}, parent)
	end
	local color = ESP.ColorFor(record.Player)
	local highlight = record.Highlight
	highlight.Adornee = record.Character
	highlight.DepthMode = Config.ESPThroughWalls and Enum.HighlightDepthMode.AlwaysOnTop or Enum.HighlightDepthMode.Occluded
	highlight.FillColor, highlight.OutlineColor = color, color
	highlight.FillTransparency = 1 - Config.ESPFillOpacity / 100
	highlight.OutlineTransparency = 1 - Config.ESPOutlineOpacity / 100
	highlight.Enabled = enabled
end

function ESP.EnsureLabel(record, enabled, distance)
	-- In combined mode, screen labels belong to the 2D layer only.
	local text = ESP.TextFor(record, distance)
	if ESP.Uses2D() or text == "" then ESP.ClearLabel(record); return end
	local anchor = PlayerCache.PartBelongsToRecord(record, record.Head) and record.Head or record.Root
	if not record.Label or record.Label.Parent ~= S.PlayerGui then
		ESP.ClearLabel(record)
		record.Label = Util.New("BillboardGui", {Name = "VisionX_ESP_Label_" .. record.Player.UserId,
			ResetOnSpawn = false, Active = false, LightInfluence = 0, MaxDistance = 0,
			Size = UDim2.fromOffset(280, 26), StudsOffsetWorldSpace = Vector3.new(0, 2, 0)}, S.PlayerGui)
	end
	if not record.LabelText or record.LabelText.Parent ~= record.Label then
		ESP.DestroyField(record, "LabelText")
		record.LabelText = ESP.NewText(record.Label, "Name")
		record.LabelText.Size = UDim2.fromScale(1, 1)
	end
	record.Label.Adornee, record.Label.Enabled = anchor, enabled
	record.Label.AlwaysOnTop = Config.ESPThroughWalls
	record.Label.MaxDistance, record.Label.PlayerToHideFrom = 0, nil
	record.Label.ResetOnSpawn, record.Label.LightInfluence = false, 0
	record.LabelText.Text, record.LabelText.TextSize = text, Config.ESPTextSize
	record.LabelText.TextColor3 = ESP.ColorFor(record.Player)
	record.LabelText.Visible, record.LabelText.TextTransparency = true, 0
end

function ESP.NewText(parent, name)
	return Util.New("TextLabel", {Name = name, BackgroundTransparency = 1, BorderSizePixel = 0,
		Text = "", TextColor3 = Theme.Accent, TextStrokeColor3 = Color3.new(0,0,0), TextStrokeTransparency = .25,
		TextSize = Config.ESPTextSize, Font = Enum.Font.GothamMedium, TextTruncate = Enum.TextTruncate.AtEnd,
		TextWrapped = false, TextScaled = false, Active = false, ZIndex = 4}, parent)
end

function ESP.NewLine(parent)
	local outer = Util.New("Frame", {Name = "Line", AnchorPoint = Vector2.new(.5,.5),
		BackgroundColor3 = Color3.new(0,0,0), BorderSizePixel = 0, Active = false, ZIndex = 2}, parent)
	local inner = Util.New("Frame", {Name = "Color", BackgroundColor3 = Theme.Accent,
		BorderSizePixel = 0, Active = false, ZIndex = 3}, outer)
	return {Outer = outer, Inner = inner}
end

function ESP.Ensure2D(record)
	if not ESP.Uses2D() then ESP.Clear2D(record); return end
	local parent, overlay = ESP.EnsureRoot(), record.Overlay
	local intact = overlay and overlay.Root and overlay.Root.Parent == parent and overlay.Objects and #overlay.Objects >= 24
	if intact then
		for _, object in ipairs(overlay.Objects) do
			if not object:IsDescendantOf(overlay.Root) then intact = false; break end
		end
	end
	if intact then return end
	ESP.Clear2D(record)
	overlay = {Lines = {}, Objects = {}}
	record.Overlay = overlay
	overlay.Root = Util.New("Frame", {Name = "Player_" .. record.Player.UserId,
		Size = UDim2.fromScale(1,1), BackgroundTransparency = 1, BorderSizePixel = 0,
		Visible = false, Active = false}, parent)
	overlay.Fill = Util.New("Frame", {Name = "Fill", BackgroundTransparency = 1,
		BorderSizePixel = 0, Active = false, ZIndex = 1}, overlay.Root)
	for index = 1, 8 do overlay.Lines[index] = ESP.NewLine(overlay.Root) end
	overlay.Tracer = ESP.NewLine(overlay.Root)
	overlay.HealthTrack = Util.New("Frame", {Name = "Health", BackgroundColor3 = Color3.fromRGB(10,12,16),
		BorderSizePixel = 0, Active = false, ZIndex = 2}, overlay.Root)
	overlay.HealthFill = Util.New("Frame", {Name = "Value", AnchorPoint = Vector2.new(0,1),
		Position = UDim2.new(0,1,1,-1), BorderSizePixel = 0, Active = false, ZIndex = 3}, overlay.HealthTrack)
	overlay.Text = ESP.NewText(overlay.Root, "Name")
	overlay.HealthText = ESP.NewText(overlay.Root, "HealthValue")
	-- Check the complete object set during recovery, never allocate in the render callback.
	overlay.Objects = overlay.Root:GetDescendants()
end

function ESP.MeasureBody(record)
	local anchor, low, high, seen = record.Root, nil, nil, {}
	if not PlayerCache.PartBelongsToRecord(record, anchor) then record.ESPBounds = nil; return end
	local function include(part)
		if seen[part] or not PlayerCache.PartBelongsToRecord(record, part) then return end
		seen[part] = true
		local relative, half = anchor.CFrame:ToObjectSpace(part.CFrame), part.Size * .5
		local right, up, look = relative.RightVector, relative.UpVector, relative.LookVector
		local extent = Vector3.new(
			math.abs(right.X)*half.X + math.abs(up.X)*half.Y + math.abs(look.X)*half.Z,
			math.abs(right.Y)*half.X + math.abs(up.Y)*half.Y + math.abs(look.Y)*half.Z,
			math.abs(right.Z)*half.X + math.abs(up.Z)*half.Y + math.abs(look.Z)*half.Z)
		local a, b = relative.Position - extent, relative.Position + extent
		low = low and Vector3.new(math.min(low.X,a.X), math.min(low.Y,a.Y), math.min(low.Z,a.Z)) or a
		high = high and Vector3.new(math.max(high.X,b.X), math.max(high.Y,b.Y), math.max(high.Z,b.Z)) or b
	end
	for _, parts in pairs(record.BodyParts) do for _, part in ipairs(parts) do include(part) end end
	include(anchor)
	local margin = Vector3.new(.1,.1,.1)
	record.ESPBounds = {Low = low - margin, High = high + margin, Anchor = anchor}
end

function ESP.ProjectBounds(record, camera)
	local bounds = record.ESPBounds
	if not bounds or bounds.Anchor ~= record.Root or not bounds.Anchor.Parent then return nil end
	local viewport = camera.ViewportSize
	if viewport.X <= 0 or viewport.Y <= 0 then return nil end
	local transform = camera.CFrame:ToObjectSpace(bounds.Anchor.CFrame)
	local vertices, near = {}, math.max(.05, math.abs(camera.NearPlaneZ or -.1))
	local minX, minY, maxX, maxY = math.huge, math.huge, -math.huge, -math.huge
	local function project(point)
		local projected = camera:WorldToViewportPoint(camera.CFrame:PointToWorldSpace(point))
		if projected.X ~= projected.X or projected.Y ~= projected.Y then return end
		minX, minY = math.min(minX, projected.X), math.min(minY, projected.Y)
		maxX, maxY = math.max(maxX, projected.X), math.max(maxY, projected.Y)
	end
	for _, x in ipairs({bounds.Low.X, bounds.High.X}) do
		for _, y in ipairs({bounds.Low.Y, bounds.High.Y}) do
			for _, z in ipairs({bounds.Low.Z, bounds.High.Z}) do
				local point = transform:PointToWorldSpace(Vector3.new(x,y,z))
				vertices[#vertices+1] = point
				if point.Z <= -near then project(point) end
			end
		end
	end
	-- Clip the twelve box edges at the camera plane. A close/partly visible
	-- character must not produce mirrored boxes or infinite screen coordinates.
	for _, edge in ipairs(ESP.Edges) do
		local a, b = vertices[edge[1]], vertices[edge[2]]
		if (a.Z < -near) ~= (b.Z < -near) then
			local t = (-near - a.Z) / (b.Z - a.Z)
			project(a + (b-a)*t)
		end
	end
	if minX == math.huge or maxX < 0 or maxY < 0 or minX > viewport.X or minY > viewport.Y then return nil end
	minX, maxX = math.clamp(minX,0,viewport.X), math.clamp(maxX,0,viewport.X)
	minY, maxY = math.clamp(minY,0,viewport.Y), math.clamp(maxY,0,viewport.Y)
	local pad = Config.ESP2DPadding
	local x, y = math.max(1, math.floor(minX-pad)), math.max(1, math.floor(minY-pad))
	local right, bottom = math.min(viewport.X-1,math.ceil(maxX+pad)), math.min(viewport.Y-1,math.ceil(maxY+pad))
	if right <= x or bottom <= y then return nil end
	return x, y, right, bottom
end

function ESP.CheckVisibility(record, camera, now)
	if Config.ESPThroughWalls then return true end
	if record.ESPVisibilityAt and now - record.ESPVisibilityAt < .12 then return record.ESPVisible end
	local params = record.ESPRayParams or RaycastParams.new()
	record.ESPRayParams = params
	params.FilterType, params.IgnoreWater = Enum.RaycastFilterType.Exclude, true
	local excluded = {}
	if S.LocalPlayer.Character then excluded[#excluded+1] = S.LocalPlayer.Character end
	params.FilterDescendantsInstances = excluded
	local origin, visible = camera.CFrame.Position, false
	for _, part in ipairs({record.Head or record.Root, record.Root}) do
		if PlayerCache.PartBelongsToRecord(record, part) then
			local delta = part.Position-origin
			local hit = delta.Magnitude > .01 and S.Workspace:Raycast(origin,delta,params) or nil
			if not hit or hit.Instance:IsDescendantOf(record.Character) then visible = true; break end
		end
	end
	record.ESPVisibilityAt, record.ESPVisible = now, visible
	return visible
end

function ESP.PaintLine(line, x1, y1, x2, y2, color, thickness, opacity, outline)
	local dx, dy = x2-x1, y2-y1
	local length = math.sqrt(dx*dx + dy*dy)
	line.Outer.Visible = length > .1
	if length <= .1 then return end
	local border = outline and 1 or 0
	line.Outer.Position = UDim2.fromOffset((x1+x2)*.5,(y1+y2)*.5)
	line.Outer.Size = UDim2.fromOffset(length,thickness+2*border)
	line.Outer.Rotation = math.deg(math.atan2(dy,dx))
	line.Outer.BackgroundColor3 = outline and Color3.new(0,0,0) or color
	line.Outer.BackgroundTransparency = 1-opacity
	line.Inner.Visible = outline
	line.Inner.Position, line.Inner.Size = UDim2.fromOffset(0,border), UDim2.new(1,0,1,-2*border)
	line.Inner.BackgroundColor3, line.Inner.BackgroundTransparency = color, 1-opacity
end

function ESP.Paint2D(record, camera, now)
	local overlay = record.Overlay
	if not overlay then return end
	overlay.Root.Visible = false
	if not ESP.ShouldShow(record.Player) or record.Character ~= record.Player.Character
		or not PlayerCache.IsAlive(record) then return end
	local distance = ESP.Distance(record, camera)
	if not ESP.InRange(distance) then return end
	local x,y,right,bottom = ESP.ProjectBounds(record,camera)
	if not x or not ESP.CheckVisibility(record,camera,now) then return end
	local width,height,color = right-x,bottom-y,ESP.ColorFor(record.Player)
	local opacity, thickness = Config.ESP2DOpacity/100, Config.ESP2DThickness
	local segments
	if Config.ESP2DStyle == "CORNERS" then
		local w,h = width*.24,height*.20
		segments = {{x,y,x+w,y},{x,y,x,y+h},{right-w,y,right,y},{right,y,right,y+h},
			{x,bottom-h,x,bottom},{x,bottom,x+w,bottom},{right-w,bottom,right,bottom},{right,bottom-h,right,bottom}}
	else
		segments = {{x,y,right,y},{right,y,right,bottom},{right,bottom,x,bottom},{x,bottom,x,y}}
	end
	for index,line in ipairs(overlay.Lines) do
		local segment = Config.ESP2DBox and segments[index]
		line.Outer.Visible = segment ~= nil and segment ~= false
		if segment then ESP.PaintLine(line,segment[1],segment[2],segment[3],segment[4],color,thickness,opacity,Config.ESP2DOutline) end
	end
	overlay.Fill.Visible = Config.ESP2DBox and Config.ESP2DFillOpacity > 0
	overlay.Fill.Position, overlay.Fill.Size = UDim2.fromOffset(x,y), UDim2.fromOffset(width,height)
	overlay.Fill.BackgroundColor3, overlay.Fill.BackgroundTransparency = color, 1-Config.ESP2DFillOpacity/100
	local humanoid = record.Humanoid
	local maxHealth = humanoid and Persistence.FiniteNumber(humanoid.MaxHealth,0) or 0
	local health = humanoid and Persistence.FiniteNumber(humanoid.Health,0) or 0
	local showHealth = Config.ESP2DHealth and maxHealth > 0
	overlay.HealthTrack.Visible, overlay.HealthText.Visible = showHealth, showHealth and Config.ESP2DHealthText
	if showHealth then
		local ratio = math.clamp(health/maxHealth,0,1)
		local hx = Config.ESP2DHealthSide == "RIGHT" and math.min(camera.ViewportSize.X-5,right+4) or math.max(0,x-9)
		overlay.HealthTrack.Position, overlay.HealthTrack.Size = UDim2.fromOffset(hx,y), UDim2.fromOffset(5,height)
		overlay.HealthFill.Size = UDim2.new(1,-2,ratio,-2*ratio)
		overlay.HealthFill.BackgroundColor3 = Color3.fromRGB(235-153*ratio,69+150*ratio,83+42*ratio)
		overlay.HealthText.Text, overlay.HealthText.TextSize = tostring(math.floor(health+.5)), Config.ESPTextSize
		overlay.HealthText.TextColor3 = overlay.HealthFill.BackgroundColor3
		overlay.HealthText.Position = UDim2.fromOffset(math.clamp(hx-20,0,camera.ViewportSize.X-44),math.min(camera.ViewportSize.Y-20,bottom+2))
		overlay.HealthText.Size = UDim2.fromOffset(44,20)
	end
	local text = ESP.TextFor(record,distance)
	overlay.Text.Text, overlay.Text.TextSize, overlay.Text.TextColor3 = text,Config.ESPTextSize,color
	overlay.Text.Visible = text ~= ""
	local textWidth = math.min(280, camera.ViewportSize.X)
	overlay.Text.Position = UDim2.fromOffset(math.clamp((x+right-textWidth)*.5,0,camera.ViewportSize.X-textWidth),math.max(0,y-Config.ESPTextSize-8))
	overlay.Text.Size = UDim2.fromOffset(textWidth,Config.ESPTextSize+6)
	overlay.Tracer.Outer.Visible = Config.ESP2DTracers
	if Config.ESP2DTracers then
		local startY = Config.ESP2DTracerOrigin == "CENTER" and camera.ViewportSize.Y*.5 or camera.ViewportSize.Y-2
		ESP.PaintLine(overlay.Tracer,camera.ViewportSize.X*.5,startY,(x+right)*.5,bottom,color,thickness,opacity,Config.ESP2DOutline)
	end
	overlay.Root.Visible = true
end

function ESP.Refresh(player)
	local record = PlayerCache.Get(player)
	ESP.ReconcileRecord(record)
	if not ESP.ShouldShow(player) or not PlayerCache.IsAlive(record) then ESP.Clear(record); return end
	local camera = S.Workspace.CurrentCamera
	local distance = ESP.Distance(record,camera)
	local enabled = ESP.InRange(distance)
	local healthy = true
	local function attempt(fn,...)
		local ok,problem = pcall(fn,...)
		if not ok then healthy = false; ESP.RecordError(problem) end
	end
	attempt(ESP.EnsureNormal,record,enabled)
	attempt(ESP.EnsureLabel,record,enabled,distance)
	if ESP.Uses2D() then attempt(ESP.MeasureBody,record) end
	attempt(ESP.Ensure2D,record)
	return healthy
end

function ESP.SafeRefresh(player)
	if not Runtime.Alive or player == S.LocalPlayer then return false end
	local record = PlayerCache.Get(player)
	if record.ESPRefreshing then return true end
	record.ESPRefreshing = true
	local ok,problem = pcall(ESP.Refresh,player)
	record.ESPRefreshing = false
	if not ok then
		ESP.RecordError(problem)
		if player.Parent ~= S.Players or record.Character ~= player.Character or not PlayerCache.IsAlive(record) then ESP.Clear(record) end
	end
	return ok and problem ~= false
end

function ESP.RefreshAll()
	if ESP.Root then ESP.Root.Enabled = Config.ESPEnabled and ESP.Uses2D() end
	for _,player in ipairs(S.Players:GetPlayers()) do ESP.SafeRefresh(player) end
end

function ESP.Render()
	if not Runtime.Alive or not Config.ESPEnabled or not ESP.Uses2D() then return end
	local camera,now = S.Workspace.CurrentCamera,os.clock()
	if not camera then
		if ESP.Root then ESP.Root.Enabled = false end
		return
	end
	if ESP.Root then ESP.Root.Enabled = true end
	for _,record in pairs(State.Records) do
		if record.Overlay then
			local ok,problem = pcall(ESP.Paint2D,record,camera,now)
			if not ok then
				if record.Overlay.Root then pcall(function() record.Overlay.Root.Visible = false end) end
				ESP.RecordError(problem)
			end
		end
	end
end

function ESP.Start()
	if ESP.Started then return end
	ESP.Started = true
	ESP.HeartbeatConnection = Runtime.Track(S.RunService.Heartbeat:Connect(function()
		if not Runtime.Alive then return end
		local now = os.clock()
		if now-ESP.LastRecovery < .2 then return end
		ESP.LastRecovery = now
		local ok,problem = pcall(ESP.RefreshAll)
		if not ok then ESP.RecordError(problem) end
	end))
	S.RunService:UnbindFromRenderStep(ESP.RenderName)
	S.RunService:BindToRenderStep(ESP.RenderName,Enum.RenderPriority.Last.Value+1,ESP.Render)
end

function ESP.Stop()
	pcall(function() S.RunService:UnbindFromRenderStep(ESP.RenderName) end)
	ESP.HeartbeatConnection = Runtime.Untrack(ESP.HeartbeatConnection)
	ESP.Started = false
	ESP.DestroyField(ESP,"Root")
	ESP.DestroyField(ESP,"Folder")
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
-- Short, finite animations. No permanent render loop or changes to saved geometry.
UI.Motion = {
	Press = 0.075, Release = 0.16, Page = 0.18, Open = 0.20, Close = 0.12,
	Pressed = {}, Windows = {}, ClosingDialogs = {},
}
UI.MotionReady = false

function UI.ResetTouchFeedback()
	for _, press in pairs(UI.Motion.Pressed) do press.Release(true) end
end

function UI.TouchFeedback(guiObject)
	if not guiObject or not guiObject:IsA("GuiObject") then return nil end
	local scale = guiObject:FindFirstChild("AAP_TouchScale")
	if not scale then
		scale = Util.New("UIScale", {Name = "AAP_TouchScale", Scale = 1}, guiObject)
	end
	if guiObject:GetAttribute("AAP_FeedbackBound") then return scale end
	guiObject:SetAttribute("AAP_FeedbackBound", true)
	local function release(instant)
		local press = UI.Motion.Pressed[guiObject]
		if not press then return end
		UI.Motion.Pressed[guiObject] = nil
		for _, connection in ipairs(press.Connections) do connection:Disconnect() end
		if instant then
			Util.StopTween(scale)
			if scale.Parent then scale.Scale = 1 end
		else
			Util.Tween(scale, {Scale = 1}, UI.Motion.Release)
		end
	end
	guiObject.InputBegan:Connect(function(input)
		if not Runtime.Alive or State.UI.LayoutEditMode or UI.Motion.Pressed[guiObject] then return end
		if input.UserInputType ~= Enum.UserInputType.Touch
			and input.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
		local press = {Input = input, Origin = input.Position, Release = release, Connections = {}}
		UI.Motion.Pressed[guiObject] = press
		press.Connections[1] = input:GetPropertyChangedSignal("UserInputState"):Connect(function()
			if input.UserInputState == Enum.UserInputState.End
				or input.UserInputState == Enum.UserInputState.Cancel then release(false) end
		end)
		press.Connections[2] = input:GetPropertyChangedSignal("Position"):Connect(function()
			if (input.Position - press.Origin).Magnitude > 10 then release(false) end
		end)
		Util.Tween(scale, {Scale = guiObject.AbsoluteSize.X >= 180 and 0.99 or 0.965},
			UI.Motion.Press, Enum.EasingStyle.Quad)
	end)
	guiObject.InputEnded:Connect(function(input)
		local press = UI.Motion.Pressed[guiObject]
		if press and press.Input == input then release(false) end
	end)
	guiObject.MouseLeave:Connect(function() release(false) end)
	guiObject.Destroying:Connect(function() release(true) end)
	return scale
end

function UI.FinishPageTransition()
	local transition = UI.Motion.PageTransition
	if not transition then return end
	UI.Motion.PageTransition = nil
	Util.StopTween(transition.Page)
	if transition.Page.Parent then transition.Page.Position = transition.Rest end
end

function UI.RevealPage(page, direction)
	UI.FinishPageTransition()
	if not UI.MotionReady or not page or not page.Parent or not page.Visible
		or State.UI.LayoutEditMode then return end
	local rest = page.Position
	local transition = {Page = page, Rest = rest}
	UI.Motion.PageTransition = transition
	page.Position = UDim2.new(rest.X.Scale, rest.X.Offset + 6 * (direction or 1), rest.Y.Scale, rest.Y.Offset)
	Util.Tween(page, {Position = rest}, UI.Motion.Page, nil, nil, function()
		if UI.Motion.PageTransition == transition then UI.Motion.PageTransition = nil end
	end)
end

-- Fade and translate the visible window without resizing its controls.
-- One progress tween drives the transition; interrupted actions reuse it.
function UI.CaptureWindowVisual(motion, object)
	if not object or not object.Parent or object == motion.Shield then return end
	if object:IsA("GuiObject") and object ~= motion.Object and not object.Visible then
		if not motion.HiddenRoots[object] then
			motion.HiddenRoots[object] = true
			motion.Connections[#motion.Connections + 1] = object:GetPropertyChangedSignal("Visible"):Connect(function()
				if object.Visible and UI.Motion.Windows[motion.Object] == motion then
					UI.CaptureWindowVisual(motion, object)
					UI.PaintWindowMotion(motion)
				end
			end)
		end
		return
	end
	if motion.Seen[object] then return end
	motion.Seen[object] = true
	local function capture(property)
		motion.Opacity[#motion.Opacity + 1] = {
			Object = object, Property = property, Base = object[property],
		}
	end
	if object:IsA("GuiObject") then
		capture("BackgroundTransparency")
		if object:IsA("TextLabel") or object:IsA("TextButton") or object:IsA("TextBox") then
			capture("TextTransparency")
			capture("TextStrokeTransparency")
		elseif object:IsA("ImageLabel") or object:IsA("ImageButton") or object:IsA("ViewportFrame") then
			capture("ImageTransparency")
		elseif object:IsA("ScrollingFrame") then
			capture("ScrollBarImageTransparency")
		end
	elseif object:IsA("UIStroke") then
		capture("Transparency")
	end
	for _, child in ipairs(object:GetChildren()) do UI.CaptureWindowVisual(motion, child) end
end

function UI.PaintWindowMotion(motion)
	if UI.Motion.Windows[motion.Object] ~= motion or not motion.Object.Parent then return end
	local hidden = math.clamp(motion.Driver.Value, 0, 1)
	for _, entry in ipairs(motion.Opacity) do
		local object, property = entry.Object, entry.Property
		if object.Parent then
			local current = object[property]
			-- Preserve changes made by the live UI while the window is moving.
			if entry.Last ~= nil and current ~= entry.Last then entry.Base = current end
			local value = entry.Base + (1 - entry.Base) * hidden
			if current ~= value then object[property] = value end
			-- Engine float properties may round the assigned Lua number.
			entry.Last = object[property]
		end
	end
	local rest = motion.Rest
	motion.Object.Position = UDim2.new(rest.X.Scale, rest.X.Offset,
		rest.Y.Scale, rest.Y.Offset + motion.Distance * hidden)
end

function UI.FinishWindowMotion(object)
	local motion = UI.Motion.Windows[object]
	if not motion then return end
	UI.Motion.Windows[object] = nil
	Util.StopTween(motion.Driver)
	for _, connection in ipairs(motion.Connections) do connection:Disconnect() end
	-- Hide before restoring paint so the last closing frame cannot flash.
	if object.Parent then
		object.Visible = motion.Visible
		object.Position = motion.Rest
	end
	for _, entry in ipairs(motion.Opacity) do
		if entry.Object.Parent then
			local current = entry.Object[entry.Property]
			if entry.Last ~= nil and current ~= entry.Last then entry.Base = current end
			entry.Object[entry.Property] = entry.Base
		end
	end
	if motion.Shield then motion.Shield:Destroy() end
	motion.Driver:Destroy()
end

function UI.SetWindowVisible(object, visible, instant)
	if not object or not object.Parent then return end
	local motion = UI.Motion.Windows[object]
	if instant == true or not Runtime.Alive or not UI.MotionReady then
		if motion then motion.Visible = visible; UI.FinishWindowMotion(object) end
		object.Visible = visible
		return
	end
	if motion and motion.Visible == visible then return end
	if not motion and object.Visible == visible then return end
	if not motion then
		local compact = object == State.UI.CompactBar
		motion = {
			Object = object, Rest = object.Position, Visible = visible,
			Distance = compact and 6 or 12,
			OpenTime = compact and 0.20 or 0.28,
			CloseTime = compact and 0.16 or 0.22,
			Opacity = {}, Seen = {}, HiddenRoots = {}, Added = {}, Connections = {},
			Driver = Util.New("NumberValue", {Name = "AAP_WindowProgress", Value = visible and 1 or 0}, object),
		}
		UI.Motion.Windows[object] = motion
		UI.CaptureWindowVisual(motion, object)
		motion.Shield = Util.New("TextButton", {
			Name = "AAP_WindowInputShield", Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 1, BorderSizePixel = 0, Text = "",
			AutoButtonColor = false, Active = true, Selectable = false,
			Visible = not visible, ZIndex = 1000000,
		}, object)
		motion.Connections[#motion.Connections + 1] = motion.Driver:GetPropertyChangedSignal("Value"):Connect(function()
			UI.PaintWindowMotion(motion)
		end)
		motion.Connections[#motion.Connections + 1] = object.Destroying:Connect(function()
			UI.FinishWindowMotion(object)
		end)
		motion.Connections[#motion.Connections + 1] = object.DescendantAdded:Connect(function(child)
			motion.Added[child] = true
			if motion.AddedPending then return end
			motion.AddedPending = true
			task.defer(function()
				motion.AddedPending = false
				if UI.Motion.Windows[object] ~= motion then return end
				for added in pairs(motion.Added) do
					local ancestor, shown = added.Parent, true
					while ancestor and ancestor ~= object do
						if ancestor:IsA("GuiObject") and not ancestor.Visible then shown = false; break end
						ancestor = ancestor.Parent
					end
					if shown and ancestor == object then UI.CaptureWindowVisual(motion, added) end
				end
				motion.Added = {}
				UI.PaintWindowMotion(motion)
			end)
		end)
	else
		Util.StopTween(motion.Driver)
		motion.Visible = visible
		motion.Shield.Visible = not visible
	end
	object.Visible = true
	UI.PaintWindowMotion(motion)
	local target = visible and 0 or 1
	local remaining = math.abs(target - motion.Driver.Value)
	local duration = math.max(0.06, (visible and motion.OpenTime or motion.CloseTime) * remaining)
	Util.Tween(motion.Driver, {Value = target}, duration,
		visible and Enum.EasingStyle.Quart or Enum.EasingStyle.Sine,
		visible and Enum.EasingDirection.Out or Enum.EasingDirection.InOut, function()
			if UI.Motion.Windows[object] == motion then UI.FinishWindowMotion(object) end
		end)
end



function UI.CaptureDialogOpacity(active)
	if active.Opacity then return end
	active.Opacity = {}
	local objects = {active.Overlay, active.Panel}
	for _, object in ipairs(active.Panel:GetDescendants()) do objects[#objects + 1] = object end
	for _, object in ipairs(objects) do
		local values = {}
		local function capture(property)
			if object[property] < 1 then values[property] = object[property] end
		end
		if object:IsA("GuiObject") then
			capture("BackgroundTransparency")
			if object:IsA("TextLabel") or object:IsA("TextButton") or object:IsA("TextBox") then
				capture("TextTransparency")
			end
			if object:IsA("ImageLabel") or object:IsA("ImageButton") then capture("ImageTransparency") end
			if object:IsA("ScrollingFrame") then capture("ScrollBarImageTransparency") end
		elseif object:IsA("UIStroke") then capture("Transparency") end
		if next(values) then active.Opacity[#active.Opacity + 1] = {Object = object, Values = values} end
	end
	active.Scale = Util.New("UIScale", {Name = "AAP_DialogScale", Scale = 1}, active.Panel)
end

function UI.AnimateDialogIn(active)
	if not active or not UI.MotionReady then return end
	UI.CaptureDialogOpacity(active)
	for _, entry in ipairs(active.Opacity) do
		for property in pairs(entry.Values) do entry.Object[property] = 1 end
		Util.Tween(entry.Object, entry.Values, UI.Motion.Open)
	end
	active.Scale.Scale = 0.985
	Util.Tween(active.Scale, {Scale = 1}, UI.Motion.Open)
end

function UI.DestroyDialog(active)
	UI.Motion.ClosingDialogs[active] = nil
	for _, connection in ipairs(active.Connections or {}) do connection:Disconnect() end
	for _, entry in ipairs(active.Opacity or {}) do Util.StopTween(entry.Object) end
	if active.Driver then Util.StopTween(active.Driver) end
	if active.Scale then Util.StopTween(active.Scale) end
	if active.Overlay and active.Overlay.Parent then active.Overlay:Destroy() end
	if active.Panel and active.Panel.Parent then active.Panel:Destroy() end
end

function UI.FlushClosingDialogs()
	for active in pairs(UI.Motion.ClosingDialogs) do UI.DestroyDialog(active) end
end

function UI.DismissDialog(active, instant)
	if not active then return end
	for _, connection in ipairs(active.Connections or {}) do connection:Disconnect() end
	UI.ResetTouchFeedback()
	-- Activated passes an InputObject; only a literal true requests immediate closing.
	if instant == true or not Runtime.Alive or not UI.MotionReady
		or not active.Panel or not active.Panel.Parent then UI.DestroyDialog(active); return end
	UI.CaptureDialogOpacity(active)
	UI.Motion.ClosingDialogs[active] = true
	for _, entry in ipairs(active.Opacity) do
		local hidden = {}
		for property in pairs(entry.Values) do hidden[property] = 1 end
		Util.Tween(entry.Object, hidden, UI.Motion.Close, nil, Enum.EasingDirection.In)
	end
	Util.Tween(active.Scale, {Scale = 0.985}, UI.Motion.Close, nil, Enum.EasingDirection.In,
		function() UI.DestroyDialog(active) end)
end

function UI.InitializeMotion()
	if UI.MotionReady then return end
	UI.MotionReady = true
	Runtime.Track(S.UIS.InputEnded:Connect(function(input)
		for _, press in pairs(UI.Motion.Pressed) do
			if press.Input == input or (press.Input.UserInputType == Enum.UserInputType.MouseButton1
				and input.UserInputType == Enum.UserInputType.MouseButton1) then press.Release(false) end
		end
	end))
	Runtime.Track(S.UIS.WindowFocusReleased:Connect(UI.ResetTouchFeedback))
end

function UI.CleanupMotion()
	UI.MotionReady = false
	UI.ResetTouchFeedback()
	UI.FinishPageTransition()
	for object in pairs(UI.Motion.Windows) do UI.FinishWindowMotion(object) end
	UI.FlushClosingDialogs()
	for object in pairs(Util.TweenJobs) do Util.StopTween(object) end
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
		local job = Util.TweenJobs[object]
		if job then
			for property in pairs(job.Goal) do
				if string.find(property, "Color", 1, true) then Util.StopTween(object, true); break end
			end
		end
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

function UI.AttachChoiceIndicator(control)
	local value = control and control.Value
	if typeof(value) ~= "Instance" then return end
	if control.ChoiceIndicator then return control.ChoiceIndicator end
	local marker = Util.New("Frame", {Name = "AAP_ChoiceIndicator", AnchorPoint = Vector2.new(.5, .5),
		Size = UDim2.fromOffset(14, 10), BackgroundTransparency = 1, BorderSizePixel = 0,
		ZIndex = value.ZIndex + 1}, value.Parent)
	for index, angle in ipairs({45, -45}) do
		local line = Util.New("Frame", {AnchorPoint = Vector2.new(.5, .5),
			Position = UDim2.fromOffset(index == 1 and 4 or 10, 4), Size = UDim2.fromOffset(8, 2),
			BackgroundColor3 = Theme.Sub, BorderSizePixel = 0, Rotation = angle,
			ZIndex = marker.ZIndex}, marker)
		Util.Corner(line, 999)
	end
	local padding = value:FindFirstChildOfClass("UIPadding")
	if not padding then padding = Util.New("UIPadding", {}, value) end
	padding.PaddingLeft = UDim.new(0, 9)
	padding.PaddingRight = UDim.new(0, 30)
	local function position()
		local p, s, a = value.Position, value.Size, value.AnchorPoint
		marker.Position = UDim2.new(p.X.Scale + s.X.Scale * (1 - a.X),
			p.X.Offset + s.X.Offset * (1 - a.X) - 16,
			p.Y.Scale + s.Y.Scale * (.5 - a.Y), p.Y.Offset + s.Y.Offset * (.5 - a.Y))
		marker.Visible = value.Visible
	end
	for _, property in ipairs({"Position", "Size", "AnchorPoint", "Visible"}) do
		value:GetPropertyChangedSignal(property):Connect(position)
	end
	control.ChoiceIndicator = marker
	control.RefreshChoiceIndicator = position
	position()
	return marker
end

function UI.PaintAttachedChoice(menu)
	if not menu.Panel.Parent then return end
	local progress = math.clamp(menu.Driver.Value, 0, 1)
	menu.Panel.Size = UDim2.fromOffset(menu.Width, math.max(1, menu.Height * progress))
	for _, entry in ipairs(menu.Opacity or {}) do
		if entry.Object.Parent then
			for property, base in pairs(entry.Values) do entry.Object[property] = 1 - (1 - base) * progress end
		end
	end
end

function UI.DismissAttachedChoice(menu, instant)
	if not menu then return end
	for _, connection in ipairs(menu.Connections) do connection:Disconnect() end
	menu.Connections = {}
	if menu.Indicator and menu.Indicator.Parent then
		if instant == true then Util.StopTween(menu.Indicator); menu.Indicator.Rotation = 0
		else Util.Tween(menu.Indicator, {Rotation = 0}, .14) end
	end
	UI.ResetTouchFeedback()
	if instant == true or not Runtime.Alive or not UI.MotionReady or not menu.Panel.Parent then
		UI.DestroyDialog(menu); return
	end
	UI.Motion.ClosingDialogs[menu] = true
	menu.DriverConnection = menu.Driver:GetPropertyChangedSignal("Value"):Connect(function() UI.PaintAttachedChoice(menu) end)
	menu.Connections[1] = menu.DriverConnection
	Util.Tween(menu.Driver, {Value = 0}, .12, Enum.EasingStyle.Cubic, Enum.EasingDirection.In,
		function() UI.DestroyDialog(menu) end)
end

function UI.CloseChoiceMenu(instant)
	local active = State.UI.ActiveChoiceMenu
	State.UI.ActiveChoiceMenu = nil
	if active and active.Attached then UI.DismissAttachedChoice(active, instant)
	else UI.DismissDialog(active, instant) end
end

function UI.CloseHelpDialog(instant)
	local active = State.UI.ActiveHelpDialog
	State.UI.ActiveHelpDialog = nil
	UI.DismissDialog(active, instant)
end

function UI.OpenHelpDialog(title, message)
	local root = State.UI.Root
	if not root or not root.Parent then return false end
	if UI.ActiveNumericSlider then UI.ActiveNumericSlider:FinishEditing(true) end
	UI.CloseChoiceMenu(true)
	UI.CloseHelpDialog(true)
	UI.FlushClosingDialogs()

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
	UI.AnimateDialogIn(State.UI.ActiveHelpDialog)
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

function UI.OpenChoiceMenu(anchor, title, choices, currentValue, onSelected, indicator)
	local root = State.UI.Root
	if not Runtime.Alive or not anchor or not anchor.Parent or not root or not root.Parent
		or type(choices) ~= "table" or #choices == 0 or State.UI.LayoutEditMode then return false end
	if UI.ActiveNumericSlider then UI.ActiveNumericSlider:FinishEditing(true) end
	local previous = State.UI.ActiveChoiceMenu
	if previous and previous.Anchor == anchor then UI.CloseChoiceMenu(); return false end
	UI.CloseChoiceMenu(true); UI.CloseHelpDialog(true); UI.FlushClosingDialogs()
	local overlay = Util.New("TextButton", {Name = "AAP_ChoiceOverlay", Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1, BorderSizePixel = 0, Text = "", AutoButtonColor = false,
		Active = true, ZIndex = 180}, root)
	local panel = Util.New("TextButton", {Name = "AAP_AttachedChoices", BackgroundColor3 = Theme.Surface2,
		BackgroundTransparency = .02, BorderSizePixel = 0, Text = "", AutoButtonColor = false,
		Active = true, ClipsDescendants = true, ZIndex = 181}, root)
	Util.Corner(panel, 12); Util.Stroke(panel, Theme.BorderSoft, .36, 1)
	local list = Util.New("ScrollingFrame", {Name = "AAP_ChoiceList", Position = UDim2.fromOffset(4, 4),
		BackgroundTransparency = 1, BorderSizePixel = 0, CanvasSize = UDim2.new(),
		ScrollBarThickness = 3, ScrollBarImageColor3 = Theme.Sub, ScrollBarImageTransparency = .4,
		ScrollingDirection = Enum.ScrollingDirection.Y, ScrollingEnabled = true,
		ElasticBehavior = Enum.ElasticBehavior.WhenScrollable, ClipsDescendants = true,
		Active = true, ZIndex = 182}, panel)
	local menu = {Attached = true, Anchor = anchor, Indicator = indicator, Overlay = overlay, Panel = panel,
		List = list, Rows = {}, Connections = {}, Width = 1, Height = 1,
		Driver = Util.New("NumberValue", {Value = 0}, panel)}
	State.UI.ActiveChoiceMenu = menu
	for index, choice in ipairs(choices) do
		local selected = choice.Value == currentValue
		local row = Util.New("TextButton", {Name = "AAP_Choice_" .. index, BackgroundColor3 = selected and Theme.CardActive or Theme.Surface2,
			BackgroundTransparency = selected and .03 or 1, BorderSizePixel = 0, Text = "",
			AutoButtonColor = false, ZIndex = 183}, list)
		Util.Corner(row, 8)
		local label = Util.New("TextLabel", {Position = UDim2.fromOffset(10, 9),
			Size = UDim2.new(1, -40, 0, 18), BackgroundTransparency = 1,
			Text = tostring(choice.Label or choice.Value), TextColor3 = selected and Theme.Accent2 or Theme.Text,
			Font = Enum.Font.GothamMedium, TextSize = 10, TextWrapped = true,
			TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 184}, row)
		local radio = Util.New("Frame", {AnchorPoint = Vector2.new(1, .5), Position = UDim2.new(1, -11, .5, 0),
			Size = UDim2.fromOffset(12, 12), BackgroundColor3 = Theme.Chip, BorderSizePixel = 0, ZIndex = 184}, row)
		Util.Corner(radio, 999); Util.Stroke(radio, selected and Theme.Accent2 or Theme.Muted, .25, 1)
		if selected then
			local dot = Util.New("Frame", {AnchorPoint = Vector2.new(.5, .5), Position = UDim2.fromScale(.5, .5),
				Size = UDim2.fromOffset(6, 6), BackgroundColor3 = Theme.Accent2, BorderSizePixel = 0, ZIndex = 185}, radio)
			Util.Corner(dot, 999); menu.SelectedIndex = index
		end
		local description
		if choice.Description and choice.Description ~= "" then
			description = Util.New("TextLabel", {Position = UDim2.fromOffset(10, 27),
				BackgroundTransparency = 1, Text = tostring(choice.Description), TextColor3 = Theme.Sub,
				Font = Enum.Font.Gotham, TextSize = 9, TextWrapped = true,
				TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Top, ZIndex = 184}, row)
		end
		menu.Rows[index] = {Card = row, Title = label, Description = description, Radio = radio, Value = choice.Value}
		row.Activated:Connect(function()
			if State.UI.ActiveChoiceMenu ~= menu or not Runtime.Alive then return end
			UI.CloseChoiceMenu()
			if onSelected then onSelected(choice.Value, choice) end
		end)
		UI.TouchFeedback(row)
	end
	local page = UI.GetPageForObject(anchor)
	local boundsObject = page or State.UI.PageHost
	local function measure(label, width)
		local ok, bounds = pcall(function()
			return game:GetService("TextService"):GetTextSize(label.Text, label.TextSize,
				label.Font, Vector2.new(math.max(width, 1), 10000))
		end)
		return ok and math.ceil(bounds.Y) + 2
			or math.ceil(#label.Text * label.TextSize * .62 / math.max(width, 1)) * (label.TextSize + 2)
	end
	local function layout()
		if State.UI.ActiveChoiceMenu ~= menu then return end
		local ancestor = anchor
		while ancestor and ancestor ~= root do
			if ancestor:IsA("GuiObject") and not ancestor.Visible then UI.CloseChoiceMenu(true); return end
			ancestor = ancestor.Parent
		end
		if not ancestor then UI.CloseChoiceMenu(true); return end
		local camera = S.Workspace.CurrentCamera or S.Camera
		local viewport = camera and camera.ViewportSize or Vector2.new(800, 450)
		local left, top, right, bottom = 6, 6, viewport.X - 6, viewport.Y - 6
		if boundsObject and boundsObject.Parent then
			local p, s = boundsObject.AbsolutePosition, boundsObject.AbsoluteSize
			left, top = math.max(left, p.X + 3), math.max(top, p.Y + 3)
			right, bottom = math.min(right, p.X + s.X - 3), math.min(bottom, p.Y + s.Y - 3)
		end
		local position, size = anchor.AbsolutePosition, anchor.AbsoluteSize
		if size.X <= 1 or position.Y + size.Y < top or position.Y > bottom or right - left < 50 then
			UI.CloseChoiceMenu(true); return
		end
		local width = math.min(math.max(size.X, 190), 330, right - left)
		local contentHeight = 0
		for _, row in ipairs(menu.Rows) do
			local titleHeight = math.max(16, measure(row.Title, width - 51))
			row.Title.Size = UDim2.new(1, -40, 0, titleHeight)
			local height = 18 + titleHeight
			if row.Description then
				local descriptionHeight = math.max(12, measure(row.Description, width - 51))
				row.Description.Position = UDim2.fromOffset(10, 12 + titleHeight)
				row.Description.Size = UDim2.new(1, -40, 0, descriptionHeight)
				height += 3 + descriptionHeight
			end
			height = math.max(36, height)
			row.Card.Position = UDim2.fromOffset(0, contentHeight)
			row.Card.Size = UDim2.new(1, -3, 0, height)
			contentHeight += height + 2
		end
		contentHeight = math.max(contentHeight - 2, 0)
		local below, above = bottom - position.Y - size.Y - 4, position.Y - top - 4
		local desired = math.min(contentHeight + 8, 208)
		local upward = below < desired and above > below
		local height = math.min(desired, upward and above or below)
		if height < 36 then UI.CloseChoiceMenu(true); return end
		menu.Width, menu.Height, menu.Upward = width, height, upward
		panel.AnchorPoint = Vector2.new(0, upward and 1 or 0)
		panel.Position = UDim2.fromOffset(math.clamp(position.X + size.X - width, left, right - width),
			upward and position.Y - 4 or position.Y + size.Y + 4)
		list.Size = UDim2.fromOffset(width - 8, height - 8)
		list.CanvasSize = UDim2.fromOffset(0, contentHeight)
		if not menu.ScrollInitialized then
			local row = menu.SelectedIndex and menu.Rows[menu.SelectedIndex]
			list.CanvasPosition = Vector2.new(0, row and math.clamp(row.Card.Position.Y.Offset - (height - row.Card.Size.Y.Offset) / 2,
				0, math.max(contentHeight - height + 8, 0)) or 0)
			menu.ScrollInitialized = true
		end
		UI.PaintAttachedChoice(menu)
	end
	menu.Layout = layout
	layout()
	if State.UI.ActiveChoiceMenu ~= menu then return false end
	-- Only a short progress tween changes the crop and opacity; text never scales.
	UI.CaptureDialogOpacity(menu)
	UI.PaintAttachedChoice(menu)
	local function track(connection) menu.Connections[#menu.Connections + 1] = connection end
	track(menu.Driver:GetPropertyChangedSignal("Value"):Connect(function() UI.PaintAttachedChoice(menu) end))
	for _, property in ipairs({"AbsolutePosition", "AbsoluteSize"}) do track(anchor:GetPropertyChangedSignal(property):Connect(layout)) end
	if boundsObject then track(boundsObject:GetPropertyChangedSignal("AbsoluteSize"):Connect(layout)) end
	local ancestor = anchor
	while ancestor and ancestor ~= root do
		if ancestor:IsA("GuiObject") then track(ancestor:GetPropertyChangedSignal("Visible"):Connect(layout)) end
		if ancestor:IsA("ScrollingFrame") then track(ancestor:GetPropertyChangedSignal("CanvasPosition"):Connect(layout)) end
		ancestor = ancestor.Parent
	end
	track(anchor.Destroying:Connect(function() if State.UI.ActiveChoiceMenu == menu then UI.CloseChoiceMenu(true) end end))
	track(root:GetPropertyChangedSignal("AbsoluteSize"):Connect(layout))
	overlay.Activated:Connect(function() UI.CloseChoiceMenu() end)
	if indicator then Util.Tween(indicator, {Rotation = 180}, .18) end
	if UI.MotionReady then Util.Tween(menu.Driver, {Value = 1}, .18)
	else menu.Driver.Value = 1; UI.PaintAttachedChoice(menu) end
	return true
end

function UI.BindChoiceMenu(control, title, choices, getCurrent, onSelected)
	if not control or not control.Card then return end
	UI.AttachChoiceIndicator(control)
	control.Card.Activated:Connect(function()
		if not Runtime.Alive or control.Available == false or State.UI.LayoutEditMode then return end
		local current = getCurrent
		if type(getCurrent) == "function" then current = getCurrent() end
		local options = type(choices) == "function" and choices() or choices
		UI.OpenChoiceMenu(typeof(control.Value) == "Instance" and control.Value or control.Card,
			title, options, current, onSelected, control.ChoiceIndicator)
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
			local height = math.max(entry.MinimumHeight or 0, math.floor(
				entry.BaseHeight * Config.ControlScale + 0.5
			))
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

	if State.UI.ESPControls then State.UI.ESPControls.Layout() end
	if State.UI.RefreshAimLayout then State.UI.RefreshAimLayout() end
	if State.UI.BodyControls then UI.LayoutBodyWorkspace(State.UI.BodyControls) end
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
		Assistant = "ARMAS",
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

	Util.Tween(control.Card, {BackgroundColor3 = enabled and Theme.CardActive or Theme.Card}, 0.16)

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
			0.16
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
			0.16
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

local function ClearPreviousVisionUI()
	for _, name in ipairs({
		"VisionX_Loading",
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

end

local function BuildVisionRootUI()
	local root = Util.New("ScreenGui", {
		Name = "AimAssistProV33",
		Enabled = false, -- Revealed only after all initialization stages succeed.
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
		Visible = false,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.52),
		Size = GetVisionMenuSize(0.88),
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
		Position = UDim2.fromOffset(8, 7),
		Size = UDim2.new(1, -16, 1, -14),
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
		Text = "AJUSTE ATUAL",
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
		UI.FinishPageTransition()
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
	if not page or not page.Parent then return end
	local previous = State.UI.ActivePage
	local previousX, nextX = 0, 0
	if previous ~= page then
		UI.FinishPageTransition()
		UI.ResetTouchFeedback()
	end
	if UI.ActiveNumericSlider then UI.ActiveNumericSlider:FinishEditing(false) end
	if State.UI.ActiveChoiceMenu then
		UI.CloseChoiceMenu(true)
	end
	if State.UI.ActiveHelpDialog then
		UI.CloseHelpDialog(true)
	end

	UI.FlushClosingDialogs()
	for button, target in pairs(State.UI.PageMap) do
		if target == previous then previousX = button.AbsolutePosition.X end
		if target == page then nextX = button.AbsolutePosition.X end
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
				BackgroundTransparency = active and 0.02 or 0.16,
				TextColor3 =
					active and Theme.Text or Theme.Sub,
			},
			0.16
		)

		if navGlow then
			Util.Tween(
				navGlow,
				{BackgroundTransparency = active and 0.36 or 1},
				0.16
			)
		end

		if navStroke then
			Util.Tween(
				navStroke,
				{
					Color = active and Theme.Accent or Theme.BorderSoft,
					Transparency = active and 0.16 or 0.68,
				},
				0.16
			)
		end

		if navTitle then
			Util.Tween(
				navTitle,
				{TextColor3 = active and Theme.Text or Theme.Sub},
				0.16
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
				0.16
			)
		end
	end

	State.UI.ActivePage = page
	if previous and previous ~= page then UI.RevealPage(page, nextX < previousX and -1 or 1) end
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
			local motion = UI.Motion.Windows[object]
			local position = motion and motion.Rest or object.Position
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

			local position = UDim2.new(
				position.X.Scale,
				clampedX - baseX,
				position.Y.Scale,
				clampedY - baseY
			)
			if motion then
				motion.Rest = position
				UI.PaintWindowMotion(motion)
			else
				object.Position = position
			end
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
		0.16
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
		0.16
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

function UI.AimText(parent, text, position, size, fontSize, color, bold)
	local label = UI.SettingsText(parent, text, position, size, fontSize, color, bold)
	UI.SetReadableText(label, fontSize)
	return label
end

function UI.StyleAimControl(control)
	local card = control.Card
	local slider = control.Track ~= nil
	local cycle = not slider and control.Value ~= nil
	local baseHeight = slider and 110 or 104
	local minimumHeight = slider and 100 or 94
	local slot = control.Record and control.Record.Card or card
	slot.Size = UDim2.new(slot.Size.X.Scale, slot.Size.X.Offset, 0,
		math.max(minimumHeight, math.floor(baseHeight * Config.ControlScale + 0.5)))
	if control.Record then control.Record.OriginalSize = slot.Size end
	for _, entry in ipairs(UI.ScalableControls) do
		if entry.Card == slot then entry.BaseHeight = baseHeight; entry.MinimumHeight = minimumHeight; break end
	end
	card.BackgroundTransparency = 0.10
	control.Title.Position = UDim2.fromOffset(12, 8)
	control.Title.Size = UDim2.new(1, slider and -100 or cycle and (control.Help and -52 or -24) or -82, 0, 20)
	control.Title.Font = Enum.Font.GothamMedium
	UI.SetReadableText(control.Title, 11)
	control.Description.Position = UDim2.fromOffset(12, cycle and 32 or 36)
	control.Description.Size = UDim2.new(1, -24, 0, 24)
	control.Description.TextWrapped = true
	control.Description.TextTruncate = Enum.TextTruncate.None
	UI.SetReadableText(control.Description, 9)
	if slider then
		control.Label.Position = UDim2.new(1, -12, 0, 6)
		control.Label.Size = UDim2.fromOffset(68, 28)
		UI.SetReadableText(control.Label, 11)
		control.Decrease.Position = UDim2.new(0, 12, 1, -8)
		control.Increase.Position = UDim2.new(1, -12, 1, -8)
		control.Track.Parent.Position = UDim2.new(0, 48, 1, -8)
	elseif cycle then
		control.Value.AnchorPoint = Vector2.new(0, 1)
		control.Value.Position = UDim2.new(0, 12, 1, -8)
		control.Value.Size = UDim2.new(1, -24, 0, 26)
		control.Value.BackgroundColor3 = Theme.Surface3
		control.Value.TextColor3 = Theme.Accent2
		control.Value.TextXAlignment = Enum.TextXAlignment.Left
		UI.SetReadableText(control.Value, 10)
		UI.AttachChoiceIndicator(control)
		if control.RefreshChoiceIndicator then control.RefreshChoiceIndicator() end
	elseif control.Switch then
		control.Switch.Position = UDim2.new(1, -12, 0, 7)
	end
	if control.Help then control.Help.Position = UDim2.new(1, -8, 0, 4) end
	return slot.Size.Y.Offset
end

function UI.CreateAimSection(page, title, note, order)
	local shell = Util.New("Frame", {
		Name = "AAP_AimSection_" .. tostring(order), LayoutOrder = order,
		Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1, BorderSizePixel = 0,
	}, page)
	Util.New("UIListLayout", {Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder}, shell)
	local header = Util.New("Frame", {Size = UDim2.new(1, 0, 0, note and 38 or 22),
		BackgroundTransparency = 1, LayoutOrder = -10}, shell)
	UI.AimText(header, title, UDim2.fromOffset(2, 1), UDim2.new(1, -4, 0, 18), 11, Theme.Text, true)
	if note then UI.AimText(header, note, UDim2.fromOffset(2, 23), UDim2.new(1, -4, 0, 14), 9, Theme.Sub) end
	local grid = Util.New("Frame", {Size = UDim2.new(1, 0, 0, 0), BackgroundTransparency = 1}, shell)
	return grid, shell
end

function UI.CreateAimFOVPreview(parent)
	local preview = Util.New("Frame", {Name = "AAP_AimFOVPreview", AnchorPoint = Vector2.new(1, .5),
		Position = UDim2.new(1, -8, .5, 0), Size = UDim2.fromOffset(84, 84),
		BackgroundColor3 = Theme.Surface2, BackgroundTransparency = .10, BorderSizePixel = 0}, parent)
	Util.Corner(preview, 12)
	local ring = Util.New("Frame", {AnchorPoint = Vector2.new(.5, .5), Position = UDim2.new(.5, 0, 0, 32),
		Size = UDim2.fromOffset(50, 50), BackgroundTransparency = 1, BorderSizePixel = 0}, preview)
	Util.Corner(ring, 999)
	local outline = Util.Stroke(ring, Theme.Accent2, .12, 1)
	local inner = Util.New("Frame", {AnchorPoint = Vector2.new(.5, .5), Position = UDim2.fromScale(.5, .5),
		Size = UDim2.fromScale(.70, .70), BackgroundTransparency = 1, BorderSizePixel = 0}, ring)
	Util.Corner(inner, 999); Util.Stroke(inner, Theme.Accent, .50, 1)
	local function line(size)
		return Util.New("Frame", {AnchorPoint = Vector2.new(.5, .5), Position = UDim2.fromScale(.5, .5),
			Size = size, BackgroundColor3 = Theme.Accent2, BackgroundTransparency = .25, BorderSizePixel = 0}, ring)
	end
	local horizontal = line(UDim2.fromOffset(34, 1))
	local vertical = line(UDim2.fromOffset(1, 34))
	local dot = line(UDim2.fromOffset(4, 4)); Util.Corner(dot, 999)
	local caption = UI.AimText(preview, "Prévia", UDim2.fromOffset(0, 65), UDim2.new(1, 0, 0, 14), 8, Theme.Sub)
	caption.TextXAlignment = Enum.TextXAlignment.Center
	return {Box = preview, Ring = ring, Outline = outline, Inner = inner,
		Horizontal = horizontal, Vertical = vertical, Dot = dot, Caption = caption}
end

function Pages.BuildVisionAim()
	local page = UI.CreatePage("Aim")
	page:SetAttribute("AAPHideScrollCue", true)
	local controls = {Page = page, PresetCards = {}, SelectedPreset = nil}
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
	local styleLabels = {RING = "Anel", DOT = "Ponto", CROSS = "Cruz", TACTICAL = "Tático", DUAL = "Dois anéis", PRECISION = "Precisão"}
	local bodyLabels = {Head = "Cabeça", Torso = "Tronco", LeftArm = "Braço esquerdo", RightArm = "Braço direito", LeftLeg = "Perna esquerda", RightLeg = "Perna direita"}
	local fixed = {Organizable = false, Scalable = false}
	local function options(description)
		return {Organizable = false, Scalable = false, Description = description}
	end
	local header = Util.New("Frame", {Name = "AAP_AimHeader", LayoutOrder = -100,
		Size = UDim2.new(1, 0, 0, 58), BackgroundTransparency = 1, BorderSizePixel = 0}, page)
	controls.Header = header
	controls.Title = UI.AimText(header, "Mira", UDim2.fromOffset(2, 3), UDim2.new(1, -132, 0, 23), 16, Theme.Text, true)
	controls.Status = UI.AimText(header, "Desativada", UDim2.fromOffset(2, 31), UDim2.new(1, -132, 0, 16), 9, Theme.Sub)
	controls.Power = Util.New("TextButton", {AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -38, 0, 10),
		Size = UDim2.fromOffset(86, 32), BackgroundColor3 = Theme.AccentSoft, BackgroundTransparency = .10,
		BorderSizePixel = 0, Text = "Ativar", TextColor3 = Theme.Text, TextSize = 11,
		Font = Enum.Font.GothamMedium, AutoButtonColor = false}, header)
	Util.Corner(controls.Power, 10); UI.TouchFeedback(controls.Power)
	controls.PowerStroke = Util.Stroke(controls.Power, Theme.Accent, .42, 1)
	controls.Help = UI.CreateHelpButton(header, "Ajuste sua mira",
		"Comece pelo FOV: ele define a área ao redor do centro da tela onde a mira procura jogadores. Isso não é a distância no mapa. Precisão maior corrige mais; suavidade maior deixa o movimento menos brusco. Você pode tocar no número para digitar um valor.",
		UDim2.new(1, 0, 0, 12))

	local area = Util.New("Frame", {Name = "AAP_AimArea", Size = UDim2.new(1, 0, 0, 100),
		BackgroundColor3 = Theme.Card, BackgroundTransparency = .10, BorderSizePixel = 0, LayoutOrder = 0}, page)
	Util.Corner(area, 14); Util.Stroke(area, Theme.BorderSoft, .66, 1)
	controls.Area = area
	controls.FOVSlider = UI.CreateSlider(area, "Área de busca", 10, 2000, Config.FOV, " px", function(value)
		Config.FOV = math.floor(value + 0.5)
		Aim.MarkAssistantCustomized()
	end, options("Maior inclui jogadores mais afastados do centro."))
	controls.FOVSlider.Card.BackgroundTransparency = 1
	for _, child in ipairs(controls.FOVSlider.Card:GetChildren()) do
		if child:IsA("UIStroke") then child.Transparency = 1 end
	end
	controls.FOVPreview = UI.CreateAimFOVPreview(area)

	local response = Util.New("Frame", {Name = "AAP_AimResponse", Size = UDim2.new(1, 0, 0, 0),
		BackgroundTransparency = 1, LayoutOrder = 1}, page)
	controls.Response = response
	controls.Accuracy = UI.CreateSlider(response, "Precisão", 0, 100, Config.Accuracy, "%", function(value)
		Config.Accuracy = math.floor(value + 0.5)
		Aim.MarkAssistantCustomized()
	end, options("Maior corrige mais a direção da mira."))
	controls.Smoothing = UI.CreateSlider(response, "Suavidade", 0, 100, Config.Smoothing, "%", function(value)
		Config.Smoothing = math.floor(value + 0.5)
		Aim.MarkAssistantCustomized()
	end, options("Maior deixa o movimento mais suave."))
	local rules = UI.CreateAimSection(page, "Escolha do alvo", nil, 2)
	controls.Rules = rules
	controls.Mode = UI.CreateCycle(rules, "Quem pode ser alvo", "Todos ou apenas o jogador marcado.", fixed)
	controls.Wall = UI.CreateCycle(rules, "Verificar paredes", "Evita focar jogadores atrás de paredes.", fixed)
	controls.Priority = UI.CreateCycle(rules, "Parte do corpo", "Região que a mira tenta usar primeiro.", fixed)
	local appearance = UI.CreateAimSection(page, "Círculo na tela", nil, 3)
	controls.Appearance = appearance
	controls.FOVVisibility = UI.CreateToggle(appearance, "Mostrar FOV", "Ocultar o círculo mantém a área de busca.", fixed)
	controls.FOVStyle = UI.CreateCycle(appearance, "Estilo do FOV", "Escolha o desenho do círculo.", fixed)
	local presets, presetShell = UI.CreateAimSection(page, "Ajustes rápidos", "Toque para aplicar uma combinação pronta.", 4)
	controls.PresetGrid = presets
	local presetData = {
		{
			Key = "SOFT",
			Title = "Suave",
			Description = "Ajuda leve com a arma atual.",
			Weapon = false,
			Mode = "SOFT",
			Color = Color3.fromRGB(77, 218, 143),
		},
		{
			Key = "STRONG",
			Title = "Forte",
			Description = "Mais correção com a arma atual.",
			Weapon = false,
			Mode = "STRONG",
			Color = Color3.fromRGB(247, 155, 67),
		},
		{
			Key = "MAXIMUM",
			Title = "Máximo",
			Description = "Maior correção com a arma atual.",
			Weapon = false,
			Mode = "MAXIMUM",
			ColorKey = "Accent",
		},
		{
			Key = "SNIPER",
			Title = "Longa distância",
			Description = "Sniper com intensidade equilibrada.",
			Weapon = "SNIPER",
			Mode = "BALANCED",
			Color = Color3.fromRGB(72, 151, 232),
		},
		{
			Key = "SMG",
			Title = "Curta distância",
			Description = "SMG com intensidade forte.",
			Weapon = "SMG",
			Mode = "STRONG",
			Color = Color3.fromRGB(167, 83, 233),
		},
	}
	local function setPresetVisual(control, active)
		UI.SetArmChoiceSelected(control, active)
	end
	State.UI.RefreshQuickPresetVisuals = function()
		controls.SelectedPreset = State.ActiveQuickPresetKey
		for key, control in pairs(controls.PresetCards) do setPresetVisual(control, key == controls.SelectedPreset) end
		if controls.PresetSummary then
			local selected = controls.SelectedPreset and controls.PresetCards[controls.SelectedPreset]
			controls.PresetSummary.Text = selected and selected.Data.Title
				or Config.AimAssistant.Customized and "Ajuste manual" or "Combinação atual"
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
			UI.Toast("Ajuste aplicado: " .. data.Title)
		end
	end
	local levels = {SOFT = 1, STRONG = 3, MAXIMUM = 4}
	for index, data in ipairs(presetData) do
		local control = UI.CreateArmChoice(presets, data.Title, data.Description, data.Weapon or nil, levels[data.Key])
		control.Data = data
		controls.PresetCards[data.Key] = control
		control.Card.LayoutOrder = index
		control.Card.MouseButton1Click:Connect(function()
			if Runtime.Alive and not State.UI.LayoutEditMode then applyPreset(data) end
		end)
	end
	local footer = Util.New("Frame", {Size = UDim2.new(1, 0, 0, 38), BackgroundTransparency = 1, LayoutOrder = 1}, presetShell)
	controls.PresetSummary = UI.AimText(footer, "Combinação atual", UDim2.fromOffset(2, 8), UDim2.new(1, -116, 0, 20), 9, Theme.Sub)
	controls.Apply = Util.New("TextButton", {AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -2, 0, 2),
		Size = UDim2.fromOffset(104, 34), BackgroundColor3 = Theme.Surface3, BackgroundTransparency = .12,
		BorderSizePixel = 0, Text = "Reaplicar", TextColor3 = Theme.Text, Font = Enum.Font.GothamMedium,
		TextSize = 10, AutoButtonColor = false}, footer)
	Util.Corner(controls.Apply, 10); Util.Stroke(controls.Apply, Theme.BorderSoft, .62, 1); UI.TouchFeedback(controls.Apply)

	function controls.Layout()
		if not Runtime.Alive or not page.Parent then return end
		local columns = page.AbsoluteSize.X - 14 >= 400 and 2 or 1
		local function grid(holder, list, heights, spanLast)
			local y = 0
			for index, card in ipairs(list) do
				local column = (index - 1) % columns
				local span = spanLast and index == #list and column == 0
				local wide = columns == 1 or span
				card.Position = UDim2.new(wide and 0 or column / columns, column == 0 and 0 or 4, 0, y)
				card.Size = UDim2.new(wide and 1 or 1 / columns, wide and 0 or -4, 0, heights[index])
				if column == columns - 1 or index == #list or span then
					y += math.max(heights[index], column == 1 and heights[index - 1] or 0) + 8
				end
			end
			holder.Size = UDim2.new(1, 0, 0, math.max(y - 8, 0))
		end
		local fovHeight = UI.StyleAimControl(controls.FOVSlider)
		local previewVisible = page.AbsoluteSize.X - 14 >= 400
		controls.FOVPreview.Box.Visible = previewVisible
		controls.FOVSlider.Card.Size = UDim2.new(1, previewVisible and -100 or 0, 0, fovHeight)
		controls.FOVSlider.Card.BackgroundTransparency = 1
		area.Size = UDim2.new(1, 0, 0, fovHeight)
		grid(response, {controls.Accuracy.Card, controls.Smoothing.Card},
			{UI.StyleAimControl(controls.Accuracy), UI.StyleAimControl(controls.Smoothing)})
		grid(rules, {controls.Mode.Card, controls.Wall.Card, controls.Priority.Card},
			{UI.StyleAimControl(controls.Mode), UI.StyleAimControl(controls.Wall), UI.StyleAimControl(controls.Priority)}, true)
		grid(appearance, {controls.FOVVisibility.Card, controls.FOVStyle.Card},
			{UI.StyleAimControl(controls.FOVVisibility), UI.StyleAimControl(controls.FOVStyle)})
		local cards, heights = {}, {}
		for index, data in ipairs(presetData) do
			cards[index] = controls.PresetCards[data.Key].Card
			heights[index] = math.max(80, math.floor(88 * Config.ControlScale + .5))
		end
		grid(presets, cards, heights, true)
	end
	function controls.Refresh()
		if not Runtime.Alive or not page.Parent then return end
		controls.Power.Text = Config.AimEnabled and "Desativar" or "Ativar"
		controls.Power.BackgroundColor3 = Config.AimEnabled and Theme.CardActive or Theme.AccentSoft
		controls.Status.Text = Config.AimEnabled and "Ativada" or "Desativada"
		controls.Status.TextColor3 = Config.AimEnabled and Theme.Accent2 or Theme.Sub
		UI.SetRailToggle(controls.RailAim, Config.AimEnabled)
		UI.SetRailToggle(controls.RailLock, Config.StickyTarget)
		UI.SetRailToggle(controls.RailESP, Config.ESPEnabled)

		controls.FOVSlider:SetValue(Config.FOV, false)
		controls.Accuracy:SetValue(Config.Accuracy, false)
		controls.Smoothing:SetValue(Config.Smoothing, false)
		controls.Mode.Value.Text =
			Config.AimMode == "AUTO" and "Todos" or "Só o escolhido"
		controls.Wall.Value.Text = Config.WallCheck and "Ativado" or "Desativado"
		controls.FOVStyle.Value.Text =
			styleLabels[Config.FOVStyle] or "Tático"
		UI.SetToggle(controls.FOVVisibility, Config.ShowFOVCircle)
		controls.FOVVisibility.Description.Text = Config.ShowFOVCircle
			and "Visível. A área de busca aparece na tela."
			or "Oculto. A área de busca continua ativa."
		controls.FOVStyle.Description.Text = Config.ShowFOVCircle
			and "Escolha o desenho do círculo."
			or "Oculto; sua escolha de estilo fica salva."
		controls.FOVPreview.Caption.Text = Config.ShowFOVCircle and "Prévia" or "Oculto"
		controls.FOVPreview.Outline.Transparency = Config.ShowFOVCircle and .12 or .65
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
			and UI.BodyPartLabel(Config.PrimaryBodyPartName)
			or bodyLabels[Config.PrimaryBodyRegion] or region and region.Label
			or "Padrão"

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
		controls.Layout()
	end
	State.UI.RefreshAimControls = controls.Refresh
	State.UI.RefreshAimLayout = controls.Layout
	State.UI.AimControls = controls
	controls.Power.Activated:Connect(function()
		if not Runtime.Alive or State.UI.LayoutEditMode then return end
		UI.SetAimEnabled(not State.AimActivationIntent, "Assistência desativada pelo menu", true)
	end)
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
			{Value = "AUTO", Label = "Todos", Description = "Procura qualquer jogador que não esteja protegido."},
			{Value = "SELECTED", Label = "Só o escolhido", Description = "Usa apenas a pessoa marcada com Focar."},
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
			{Value = true, Label = "Ativado", Description = "Evita focar jogadores atrás de paredes."},
			{Value = false, Label = "Desativado", Description = "Não verifica se existe algo na frente do jogador."},
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
			Label = bodyLabels[regionName] or region and region.Label or regionName,
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
			Label = styleLabels[styleName] or styleName,
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
		if not Runtime.Alive or State.UI.LayoutEditMode then return end
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
			UI.Toast("Ajuste atual aplicado")
		end
	end)
	local advancedContent, advancedGroup = UI.CreateExpandableGroup(page, "Ajustes avançados",
		"Movimento e arma.", false)
	State.UI.AimAdvancedContainer = advancedContent
	controls.AdvancedGroup = advancedGroup
	advancedGroup.Shell.LayoutOrder = 5
	local lastWidth = -1
	page:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
		if page.AbsoluteSize.X ~= lastWidth then lastWidth = page.AbsoluteSize.X; controls.Layout() end
	end)
	page:GetPropertyChangedSignal("Visible"):Connect(function()
		if page.Visible then controls.Refresh() end
	end)
	controls.Refresh()
	return page
end

function UI.CreateMenuGlyph(parent, size, background, color)
	local box = Util.New("Frame", {
		Size = UDim2.fromOffset(size, size), BackgroundColor3 = background,
		BackgroundTransparency = .15, BorderSizePixel = 0,
	}, parent)
	Util.New("UICorner", {CornerRadius = UDim.new(0, size * .28)}, box)
	local glyph, draw = {Box = box, Ink = {}}, {}
	local unit = size / 32
	local function ink(object, property)
		glyph.Ink[#glyph.Ink + 1] = {object, property}
	end
	local function shape(host, x, y, width, height, radius, hollow)
		local object = Util.New("Frame", {
			Name = hollow and "IconOutline" or "IconFill",
			Position = UDim2.fromOffset(x * unit, y * unit),
			Size = UDim2.fromOffset(width * unit, height * unit),
			BackgroundColor3 = color, BackgroundTransparency = hollow and 1 or 0,
			BorderSizePixel = 0,
		}, host)
		Util.New("UICorner", {CornerRadius = UDim.new(0, (radius or 0) * unit)}, object)
		if hollow then
			local stroke = Util.Stroke(object, color, 0, 1.8 * unit)
			local centered = pcall(function() stroke.BorderStrokePosition = Enum.BorderStrokePosition.Center end)
			if not centered then
				-- Keep the same outline bounds on clients with the older border renderer.
				object.Position = UDim2.fromOffset((x + .9) * unit, (y + .9) * unit)
				object.Size = UDim2.fromOffset((width - 1.8) * unit, (height - 1.8) * unit)
				object:FindFirstChildOfClass("UICorner").CornerRadius = UDim.new(0, math.max(0, (radius or 0) - .9) * unit)
			end
			ink(stroke, "Color")
		else
			ink(object, "BackgroundColor3")
		end
		return object
	end
	function draw.Fill(x, y, width, height, radius)
		return shape(box, x, y, width, height, radius, false)
	end
	function draw.Outline(x, y, width, height, radius)
		return shape(box, x, y, width, height, radius, true)
	end
	function draw.Line(x1, y1, x2, y2, thickness)
		local dx, dy = x2 - x1, y2 - y1
		local length = math.sqrt(dx * dx + dy * dy)
		local object = Util.New("Frame", {
			Name = "IconLine", AnchorPoint = Vector2.new(.5, .5),
			Position = UDim2.fromOffset((x1 + x2) * .5 * unit, (y1 + y2) * .5 * unit),
			Size = UDim2.fromOffset((length + (thickness or 1.8)) * unit, (thickness or 1.8) * unit),
			Rotation = math.deg(math.atan2(dy, dx)), BackgroundColor3 = color, BorderSizePixel = 0,
		}, box)
		Util.New("UICorner", {CornerRadius = UDim.new(.5, 0)}, object)
		ink(object, "BackgroundColor3")
		return object
	end
	function draw.Bow()
		-- One clipped circular border, with round tips, instead of joined segments.
		local clip = Util.New("Frame", {
			Name = "BowCurve", Position = UDim2.fromOffset(15 * unit, 5 * unit),
			Size = UDim2.fromOffset(12 * unit, 22 * unit),
			BackgroundTransparency = 1, BorderSizePixel = 0, ClipsDescendants = true,
		}, box)
		shape(clip, -10, 1, 20, 20, 10, true)
		draw.Fill(14.1, 5.1, 1.8, 1.8, .9)
		draw.Fill(14.1, 25.1, 1.8, 1.8, .9)
	end
	return glyph, draw
end

function UI.SetMenuGlyphColor(glyph, themeKey)
	for _, entry in ipairs(glyph.Ink) do
		entry[1][entry[2]] = Theme[themeKey]
		-- Preserve the selection color when the user changes the menu's theme.
		entry[1]:SetAttribute("AAPTheme_" .. entry[2], themeKey)
	end
end

-- Native fallback rectangles: five bytes (x, y, width, height, opacity), each stored as value + 33.
UI.WeaponSilhouettes = {
	RIFLE = {Index = 1, Runs = ";*#\"\"7+\"\"\"8+\"\"#9+#\"$;+##%=+\"\"#L+\"\"\"U+\"\"\"V+\"\"#W+\"\"$X+\"\"#3,\"\"\"4,\"\"#5,\"\"$6,&\"%=,\"\"$J,\"#\"K,#'%M,\"\"\"T,\"#$U,$#%X,\"\"$3-\"\"$4-&\"%9-\"\"$:-\"\"#;-\"\"$<-##%M-\"##X-\"\"%3.\"##4.##%6.\"\"#7.#\"\";.\"\"\">.\"\"\"G.\"\"\"H.\"\"#I.#\"$P.\"\"\"Q.\"\"#R.#\"$T.#\"%V.\"\"$W.\"\"#X.\"\"\"6/\"#\"</\"\"#=/\"*%>/\"\"#B/\"\"\"C/\"\"#D/#\"$F/&\"%M/\"$%N/\"\"$O/&#%T/\"\"$30\"\"\"40#\"$<0\"\"\">0\"\"$?0\"\"#@0\"\"$A0'\"%G0\"\"$H0\"#\"I0\"##J0\"$%N0\"#%T0\"\"%81#\"\":1\"\"#;1\"\"$<1\"&%>1&\"%C1\"\"#D1\"\"\"E1\"#$F1\"&%G1\"\"\"O1\"\"%P1#\"$R1\"\"#S1#\"\"42\"\"\"52\"\"#62#\"$82%&%>2%&%B2\"\"$C2\"\"\"D2\"\"#G2$\"%K2\"\"%L2\"\"$M2\"\"#N2#\"\"23\"\"$33&)%B3%$%G3##%I3\"#$J3\"\"\"24\"(%%5$\"\"/5\"\"\"05\"\"#15\"\"$G5\"\"$H5\"\"#I5\"\"\"$6\"\"#%6'*%+6$\"$.6%&%<6\"\"$B6\"\"$C6#\"#E6\"\"\"$7\"\"$+7$&%87\"\"$97\"\"#:7\"\"\">7$'%A7\"\"##8\"#\"$8\"$%88\"##=8\"#$A8\"\"$A9\")%B9\"\"\"8:\"\"$9:\"\"\"=:\"\"%B:\"\"$$;\"\"$.;#\"%0;#\"$2;\"\"#3;\"\"$4;&(%9;\"\"$=;\"\"$B;\"'%C;\"\"#$<\"\"#+<#\"%-<\"\"$.<#\"\"3<\"##9<\"##=<\"\"\"C<\"&%D<\"\"#$=\"#\"+=\"\"%,=\"\"$>=\"\"$?=##%D=\"%%E=\"\"#+>\"\"#3>\"&$9>\"$\">>\"\"\"E>\"#%F>\"\"$G>\"\"\"%?\"#$&?%\"%*?\"\"\"??\"\"#@?\"\"%F?\"\"#&@#\"%(@\"\"$)@\"\"\"@@\"\"#E@\"\"\"%A\"\"#&A\"\"%'A\"\"#AA\"\"\"BA#\"$DA\"\"\"4B$\"%7B\"\"$8B\"\"#4C#\"\""},
	SMG = {Index = 2, Runs = "H)\"#\"I)\"\"$J)\",%K)\"\"\"I*\"\"%K*\"##I+\"\"$R+\"\"\"S+\"\"#T+#\"$V+\"\"#;,\"\"\"<,\"\"#=,\"\"\"D,\"\"\"E,#\"#G,\"\"$H,#$%K,\"\"\"R,\"\"$S,$%%V,\"\"$7-\"#\"8-\"\"#9-\"\"$:-$)%=-\"\"#?-#\"\"A-\"\"#B-\"\"$C-&#%K-\"(%L-\"\"\"N-#\"\"P-\"\"#Q-\"\"$R-\"#%V-\"$%8.#,%=.#\"$?.%&%L.\"'%M.\"\"$N.%\"%W.\"#\"=/#%%C/#\"%E/\"\"$F/\"\"#G/\"#\"H/\"##I/\"&%M/%\"%Q/\"\"$R/\"\"#70\"\"#C0\"'%D0\"\"#M0\"$%N0\"\"#O0\"\"\"S0#\"#U0\"\"\"61\"\"\"71\")%D1&)%N1\"\"\"42\"\"\"52\"\"#62\"(%N2\"##03\"\"\"13\"\"#23\"\"$33$'%=3\"\"%>3\"\"$?3#\"#A3\"\"$B3\"$%M3\"\"$04\"\"$14#&%A4\"\"#I4\"\"$J4\"\"#K4\"\"\"05\"\"#:5#,%<5\"\"$A5\"\"\"I5\"\"\"-6\"\"\".6#\"#06\"\"$<6\"+%B6\"\"\"C6\"\"$I6\"\"#(7#\"\"*7\"\"#+7\"\"$,7&\"%=7\"\"$>7\"*\"C7\"\"#I7\"\"$%8\"\"#&8#\"$(8(\"%/8#\"$=8\")%I8\"(%J8\"\"\"%9'\"%+9\"\"$,9\"\"#-9#\"\"19\"\"$29#\"%49\"\"$59\"\"#69$\"\"99\"&%D9\"\"#E9%#%J9\"\"$%:\"\"$&:$%%):\"#\"1:#\"\"8:\"\"\"J:\"'%K:\"\"#%;\"\"#E;\"\"\"F;$\"%K;\"&%L;\"\"#%<\"\"\")<\"\"#F<\"\"#G<#\"%L<\"$%M<\"\"#)=\"\"$G=\"\"#H=\"\"%M=\"\"%N=\"\"#&>\"\"$'>$\"%9>\"$$H>\"\"#M>\"\"$N>\"\"\"&?\"\"#'?\"\"$(?\"\"#)?\"\"\"I?\"\"#L?\"\"#:@\"\"$;@#\"#=@\"\"\"J@#\"\""},
	SNIPER = {Index = 3, Runs = "B&\"\"\"C&#\"#E&\"\"$F&\"*%G&\"\"$B'%)%G'\"(%H'\"\"\"A(\"\"$H(\"\"#=)\"\"\">)#\"#@)\"\"$A)\"&%H)\"#$8*#\"\":*\"\"#;*\"\"$<*&%%5+\"\"#6+#\"$8+%%%H+\"$%I+\"#\"4,\"\"\"5,$$%V,\"\"\"W,#\"#Y,\"\"$Z,\"\"#1-\"\"\"2-\"\"#3-\"\"$4-\"#%I-\"\"#V-\"\"$W-$\"%Z-\"\"$1.\"\"#2.#\"%<.#\"%>.\"\"$?.\"\"#@.\"\"\"A.\"\"#G.\"\"$H.\"\"#V.\"\"#W.\"\"%X.#\"$Z.\"\"#1/\"\"\"2/\"\"%3/\"\"$4/\"\"#5/\"\"$6/%\"%:/\"#$;/#\"\"A/\"$\"B/#-%D/\"\"#E/\"\"\"Q/\"\"\"R/#\"#T/\"\"$U/##%W/\"##50\"\"\"60\"\"#70\"\"\"80\"\"$90\"(%D0\"\"\"F0#\"\"H0\"\"#I0#\"$L0#\"\"N0\"\"#O0\"\"$P0&\"%81\"\"#:1\"'%;1#\"$D10\"%S1#\"$U1\"\"#V1\"\"\"82\"#\";2#%%=2#\"#?2#\"$A2\"+%D2,\"%O2\"\"$P2\"\"#Q2#\"\"=3%'%D3($%K3#\"#M3\"\"\"34#\"\"54\"\"#64\"\"$74#$%15\"\"\"25\"\"$35%(%K5\"\"\"26\"'%;6\"\"%<6\"\"$D6%\"%H6\"\"$I6#\"#.7#\"\"07\"\"#17\"\"$77\",%87\"\"$97\"\"#:7\"\"\"D7\"#$E7\"\"#F7\"\"\"'8$\"\"*8#\"#,8#\"$.8%&%88\"\"\";8#\"\"$9\"#\"%9\"\"$&9)'%89\"\"$99\"\"#:9#\"$<9\"\"#=9\"\"\"?9\"\"$@9\"$%D9\"#%%:\"&%8:$#%;:\"\"\"?:\"\"#E:\"#\"$;\"##?;\"\"\"B;\"\"%C;\"\"$D;\"\"#2<\"\"$3<\"\"#4<\"\"\"5<\"##6<\"'%8<#%%:<\"\"$@<#\"\"$=\"#\".=#\"%0=\"\"#:=\"\"#.>\"\"%/>\"\"\"5>\"\"$:>\"\"\"%?\"#$&?(\"%-?\"\"$.?\"\"\"5?\"$%&@'\"%,@\"\"#4@\"$\"8@\"\"%9@\"\"$%A\"\"#&A%\"%*A\"\"$+A\"\"\"8A\"\"$9A\"\"\"%B\"\"\"&B$\"%)B\"\"$5B\"\"#6B#\"\"&C#\"%(C\"\"#&D\"\"\""},
	SHOTGUN = {Index = 4, Runs = "U'#\"\"U(\"\"$V(\"'%W(\"#\"U)\"\"#S*#\"\"U*\"\"$W*\"\"#O+\"\"\"P+\"\"#Q+#\"$S+$$%W+\"#%X+\"\"#J,\"\"\"K,#\"#M,\"\"$N,&$%X,\"\"$E-#\"\"G-\"\"#H-\"\"$I-&+%W-\"\"$X-\"\"#A.\"\"\"B.\"\"#C.#\"$E.%+%S.\"\"$T.\"\"#U.#\"\"</\"\"\"=/\"\"#>/#\"$@/&+%N/\"(%O/\"\"$P/\"\"#Q/\"\"\"70#\"\"90\"\"#:0\"\"$;0&'%O0\"'%P0#\"$51\"\"\"61&'%P1##%R1\"\"#S1\"\"$T1\"#%U1\"#\"52\"'%R2#\"%43\"\"#P3\"\"%Q3#\"#S3\"\"\"04#\"\"24\"\"#34\"\"$44\"$%P4\"#$-5\"\"#.5#\"$05%$%+6\"\"\",6\"\"$-6$*%;6\"\"%<6\"\"$=6\"\"#>6#\"%N6\"\"$O6\"\"#P6\"\"\"*7\"\"\"+7#,%47\"\"$67\"\"%77#\"$97\"\"#:7\"\"\">7\"\"$?7\"#%I7#\"$K7\"\"#L7\"\"\")8\"\"#*8\"-%08\"&%18\"\"$28#\"\"58\"\"$68\"\"\">8\"\"#E8\"\"$F8\"\"#G8#\"\"(9\"\"#)9\",%19\"\"#49\"\"#59\"\"%>9\"\"\"?9#\"$A9\"\"#B9#\"\"&:\"\"\"':\"\"$(:\"+%1:#\"\"3:\"\"#4:\"\"%5:\"\"$%;\"\"\"&;#(%1;$\"%4;\"\"$5;\"\"\"%<\"\"$1<\"\"$2<\"\"\"$=\"\"#%=\"%%0=\"\"$$>\"#$0>\"\"\"-?#\"%/?\"\"\"$@\"\"#-@\"\"%.@\"\"#%A\"\"#-A\"\"$&B\"\"#'B\"\"%+B\"#%,B\"\"$'C\"\"#,C\"\"\"(D\"\"\")D#\"$+D\"\"\""},
	PISTOL = {Index = 5, Runs = "K$\"\"\"H%\"#\"I%#\"$K%\"-%L%\"\"\"I&#,%L&\"\"$M&#\"#F'#\"\"H'\"\"#L'$*%O'\"\"\"B(\"\"\"C(\"\"#D(#\"$F($*%O(\"\"#=)\"\"\">)#\"#@)\"\"$A)&*%O)\"\"$/*#\"\"8*#\"\":*\"\"#;*\"\"$<*&+%O*\"'%-+#\"$/+\"+%0+\"\"$4+\"\"\"5+\"\"#6+#\"$8+%+%P+\"#\"-,\"#$.,\"+%0,\"$%1,#\"$3,&#%,-\"\"#1-##%P-\"\"#+.\"#$,.#&%3.#\"%5.\"\"$6.#\"%P.\"\"$0/#\"$2/##%4/\"\"\"6/\"#$7/\"8%P/\"\"#+0\"\"#40\"\"#L0#\"$N0\"\"#O0\"\"\"+1\"\"\"01\"\"\"21\"#$31\"6%41\"#$61\"\"\"F1\"\"%G1#\"$I1\"\"#J1\"\"\"02\"\"#52\"\"#62\"\"$A2%\"%E2\"$$F2\"\"\",3\"#$-3\"$%03\"\"$13\"\"#23\"4%43$4%A3\"\"$B3\"\"#C3\"\"$D3\")%04#\"%<4#\"$>4\"\"#?4\"\"\"C4\"##,5\"\"#/5#\"$15\"2%85$%%;5\"\"$E5\"&%F5\"#\"-6\"\"\"06\"\"$;6\"\"#C6\"#\"07\"0%;7\"#\"F7\"$#/8\"\"\"C8\"\"#/9\"\"#89#,%:9\"#$@9\"\"\"A9\"\"#B9\"\"$C9\"#%/:\"\"$;:#\"\"=:\"\"#>:\"\"$?:%\"%E:\"\"$/;\",%:;)\"%B;#\"$D;\"\"\".<\"\"\":<%\"%><\"\"$?<\"\"#@<#\"\".=\"\"#:=\"\"%;=\"\"#<=\"\"\".>\"\"$:>\"#$.?\"(%-@\"\"\":@\"\"#-A\"\"#:A\"#\"-B\"#$-D\"\"%8D\"#%9D\"\"$-E\"\"#9E\"\"#/F&\"\"4F$\"#7F\"\"$8F\"\"#"},
	DMR = {Index = 6, Runs = "?(\"\"\"@(\"\"#A(\"\"\"<)\"\"#=)\"\"$>)$(%A)\"#$;*\"\"\"<*#&%7+\"\"\"8+\"\"#9+#\"$;+\"%%A+\"%%B+\"#\"X+\"\"\"5,\"\"$6,&$%U,\"\"#V,\"\"$W,#%%Y,\"\"\"5-\"#%B-\"\"#U-##%Y-\"\"#2.\"\"\"3.\"\"#4.\"\"$B.\"\"$S.\"\"\"T.\"\"#Y.\"#$2/#\"$4/\"\"#5/\"\"$6/$\"%9/\"\"$:/\"\"#;/#\"\"=/\"\"$A/\"\"#B/\"\"\"N/\"\"\"O/\"\"#P/\"#$Q/$\"%T/#\"$V/\"\"%60\"\"$70\")%80\"\"$>0\"#\"?0#)%A0\"\"\"C0#\"\"E0\"\"#F0\"\"$G0\"&%H0#\"$J0#\"#L0\"#$M0$\"%Q0\"\"#R0\"\"\"U0\"\"\"V0\"\"$W0\"\"#X0\"\"\"61\"\"#81\"&%91\"\"\"A1\"\"$B1&\"%H1%$%M1\"\"\"62\"\"\"92\"\"#:2\"\"\";2\"\"#<2#\"$>2\"'%A2#\"%C2\"\"$D2\"\"#E2\"#\"F2\"#$L2\"\"#53\"\"\"63\"\"#93&#%A3\"\"\"L3\"\"$14\"\"\"24\"\"#34\"\"$44$(%A4#\"$C4%\"%H4#\"$J4\"\"#K4\"\"\"/5\"\"\"05\"\"$15$(%95#\"%;5#\"$=5\"$%A5%\"%E5\"\"#F5#\"\".6\"\"\"/6#'%86\"\"#96\"\"\"<6\"\"#A6$(%D6\"\"$+7#\"\"-7\"\"#.7\"'%<7\"#$D7\"'%'8\"\"\"(8\"\"#)8#\"$+8$'%78\"#$=8\"\"#>8\"\"\"?8\"\"#@8\"%%$9\"\"\"%9\"\"$&9&(%89\"\"#99\"\"$:9\"##?9\"#\"$:#\"%7:$%%E:\"$\"$;\"\"$%;\"%%4;#\"$6;\"(%:;\"#\"$<\"\"#/<\"\"%0<\"\"#1<#\"\"5<\"##@<\"#$$=\"#\".=\"\"$A=\"\"%B=#\"$D=\"\"#+>#\"%->\"\"#5>\"%$7>#$%9>\"#$@>\"\"\"%?\"#$+?\"\"$,?\"\"\"&@%\"%*@\"\"#9@\"\"#%A\"\"\"&A#\"%(A\"\"$)A\"\"\"7A\"\"%8A\"\"$9A\"\"\"&B#\"#5B\"\"#6B#\"\""},
	LMG = {Index = 7, Runs = ";*#\"\"=*\"\"#>*#\"$@*\"\"#7+\"\"\"8+\"\"#9+#\"$;+'\"%A+\"\"#U+\"\"\"V+\"\"#W+#\"$Y+\"#\"5,\"\"\"6,)\"%>,\"\"$?,#\"%A,\"#$T,\"#\"U,%$%5-\"#$6-$\"%9-#\"$;-\"\"#<-\"\"\"?-\"\"$@-\"&%Y-\"\"#6.#3%8.\"\"\"?.\"\"#A.\"%%G.#\"\"P.\"\"\"Q.\"\"#R.\"\"$S.#\"%Y.\"\"$5/\"\"#?/\"\"\"B/#\"#D/#\"$F/#(%H/\"\"$K/\"\"\"L/\"\"#M/#\"$O/&\"%T/#\"$V/\"\"%W/\"\"$X/\"\"#Y/\"\"\"50\"\"\"80\"\"\"=0#\"\"?0\"\"#B0%\"%H0\"'%I0\"\"$J0&$%O0\"\"$P0###R0\"\"\"81\"\"#91\"\"\":1\"\"#;1\"\"$<1%\"%B1\"\"$C1\"\"#D1#\"%I1\"&%O1\"\"#42\"\"\"52\"\"#82'(%>2\"\"#?2\"#\"C2\"\"\"D2\"\"$E2\"(%O2$#%R2\"\"\"23\"\"$33$(%>3\"\"\"@3\"\"#A3\"\"$B3$&%J3\"\"$K3#\"#M3\"\"\"N3\"'$R3\"#%24\"\"%>4%&%J4\"##O4#\"%Q4\"\"\"S4\"\"$25\"\"#O5\"'%P5\"#$R5\"\"#S5\"\"%T5\"\"#$6#\"\"06\"\"\"16\"\"#26\"\"$F6\"+%G6\"\"#H6\"\"\"S6\"\"$T6\"#%U6\"\"\"#7\"\"$$7&(%)7%\"$-7\"\"#.7\"\"$/7%$%P7\"\"#S7\"\"\"U7\"\"$#8\"\"%)8'%%B8\"\"$C8#\"#G8\"\"\"P8\"#\"T8\"\"#U8\"\"%V8\"\"##9\"\"$89#\"%:9\"\"$;9##%=9\"\"$>9#\"#@9\"\"\"E9\"#$G9\"##N9\"$%U9\"\"$V9\"\"%W9\"\"\"#:\"##/:$\"%2:#\"$4:##%8:\"#%9:\"\"\"=:\"\"#D:\"\"\"V:\"\"\"/;\"\"#0;\"\"\";;\"\"$<;\"%%=;\"\"$?;#\"\"A;\"\"#B;#\"$D;#'%G;\"#$O;\"\"##<\"\"\")<%\"%-<\"\"$4<\"&$5<\"&%8<\"%$;<\"\"#=<\"'%><\"\"$?<&&%)=$\"%,=\"\"#;=\"#\">=\"&%G=\"$%$>\"\"$%>&\"%*>\"\"$+>\"\"\"H>\"#\"$?\"\"#%?%\"%)?\"\"#<?\"#$$@\"\"\"%@#\"%'@\"\"$(@\"\"\"6@\"\"%7@\"\"$8@\"\"\"F@\"\"$G@\"\"#%A#\"#4A#\"\"<A\"\"#?A#\"%AA#\"$CA\"\"#DA\"\"\"=B#\"#?B#\"\""},
	PROJECTILE = {Index = 8, Runs = ":$(\"\"8%\"$\"9%*#%B%\"\"$C%\"\"#D%\"\"\"B&$\"%E&\"\"$F&\"\"#9'\"$%:'\"\"$;'&\"\"@'#\"#B'\"\"$C'%\"%G'\"\"$H'\"\"\"8(\"\"#:(\"\"#D(\"\"#E(\"\"$F($\"%I(\"\"#8)\"\"$:)\"\"\"F)\"\"#G)$\"%J)\"\"$7*\"\"\"8*\"$%9*\"\"$G*\"\"\"H*\"\"$I*#\"%K*\"\"$7+\"\"#9+\"\"#I+\"\"$J+#\"%L+\"\"#O+\"\"\"P+\"\"$Q+\"\"\"7,\"\"$9,\"\"\"J,\"\"$K,##%M,\"\"\"O,\"\"#P,#\"%R,\"\"#6-\"\"\"7-\"$%8-\"\"$J-\"\"\"M-\"$%N-\"\"\"P-\"\"#Q-#\"%S-\"\"$T-\"\"\"6.\"\"#8.\"\"#K.\"\"\"L.\"\"%N.\",%O.\"\"\"Q.\"\"\"R.\"\"$S.#\"%U.\"\"#6/\"\"$8/\"\"\"L/\"\"#O/\"\"$S/\"\"$T/#$%V/\"\"$50\"\"\"60\"$%70\"\"$M0\"\"#O0\"'%P0#\"$R0#\"%V0\"\"%51\"\"#71\"\"#I1\"\"\"J1#\"#L1\"\"$M1\"\"%P1#\"%R1\"\"$S1\"##V1\"\"#52\"\"$72\"\"\"D2#\"\"F2\"\"#G2\"\"$H2&\"%M2\"\"$P2\"\"$T2\"#%U2\"\"$43\"\"\"53\"'%63\"\"$@3\"\"\"A3\"\"#B3\"\"$C3'\"%I3\"\"$J3\"\"#K3\"\"\"P3\"\"#R3\"\"\"S3\"#%U3\"\"\"44\"\"#64\"\"#;4\"\"\"<4#\"#>4\"\"$?4&\"%D4\"\"$E4\"\"#F4#\"\"M4\"\"\"P4\"\"\"R4\"\"$T4\"\"#*5#\"#,5\"\"\"45\"\"$65#\"\"85\"\"#95\"\"$:5&\"%?5#\"$A5\"\"#B5\"\"\"M5\"#$Q5\"##R5\"\"%S5\"\"$*6\"\"\"+6#\"%-6\"\"$.6\"\"#/6\"\"\"26\"\"\"36\"\"#46\"#%66&\"%;6\"\"$<6\"\"#=6\"\"\"O6\"\"$R6\"\"$S6\"\"\"+7\"\"\",7)\"%67\"#$77\"\"#87#\"\"L7\"\"\"M7\"&%O7\"\"#)8\"\"\"*8\"\"#+8\"\"$,8'\"%28\"\"#38\"\"\"48\"\"#L8\"\"#O8\"\"\"(9\"\"\")9)\"%19\"\"\"59\"\"#69\"\"%79\"\"$L9\"\"$N9\"\"$):\"\"#*:\"\"\",:\"#$-:#\"%/:\"\"$0:\"\"\"6:\"\"$7:\"\"%8:\"\"$K:\"\"\"L:\"%%N:\"\"#-;\"\"%.;\"\"#7;\"\"$8;\"\"%9;\"\"$K;\"\"$+<\"\"\",<\"\"%-<\"\"\"8<\"\"$9<\"\"%:<\"\"$J<\"\"#K<\"$%M<\"\"#9=\"\"$:=\"#%;=\"\"#I=\"\"\"J=\"$%9>\"\"\";>\"#%<>\"\"#H>\"\"\"I>\"$%L>\"\"\":?\"\"\"<?\"#%=?\"\"#G?\"\"\"H?\"$%K?\"\"#;@\"\"\"=@\"#%>@\"\"\"F@\"\"#G@\"#%J@\"\"#<A\"\"\">A\"#%?A\"\"\"DA\"\"#EA##%IA\"\"\"=B\"\"#?B\"#%@B\"\"\"BB\"\"#CB\"\"$DB\"#%GB\"\"$HB\"\"\">C\"\"#@C%\"%EC\"\"$FC\"\"\"?D\"\"$@D$\"%CD\"\"$DD\"\"\"?E\"\"#@E\"\"$AE\"\"#BE\"\"\""},
}

-- Embedded PNG artwork, decoded only as an image. It never downloads or runs code.
-- The same silhouettes are available as native shapes if local images are unavailable.
function UI.GetWeaponIconAsset()
	if UI.WeaponIconAsset ~= nil then return UI.WeaponIconAsset or nil end
	UI.WeaponIconAsset = false
	local register = type(getcustomasset) == "function" and getcustomasset
		or type(getsynasset) == "function" and getsynasset
	if not register or type(writefile) ~= "function" then return nil end
	local ok, asset = pcall(function()
		local encoded = [[
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
AAAASUVORK5CYII=
]]
		local alphabet, codes = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/", {}
		for index = 1, #alphabet do codes[string.byte(alphabet, index)] = index - 1 end
		encoded = encoded:gsub("%s", "")
		local bytes = {}
		for index = 1, #encoded, 4 do
			local a, b, c, d = string.byte(encoded, index, index + 3)
			local value = codes[a] * 262144 + codes[b] * 4096 + (codes[c] or 0) * 64 + (codes[d] or 0)
			local first = math.floor(value / 65536)
			local second = math.floor(value / 256) % 256
			bytes[#bytes + 1] = c == 61 and string.char(first)
				or d == 61 and string.char(first, second)
				or string.char(first, second, value % 256)
		end
		local png = table.concat(bytes)
		local path = "VisionX_Weapons_35_0_3.png"
		local readOK, cached = false, nil
		if type(readfile) == "function" then readOK, cached = pcall(readfile, path) end
		if not readOK or cached ~= png then writefile(path, png) end
		return register(path)
	end)
	if ok and type(asset) == "string" and asset ~= "" then UI.WeaponIconAsset = asset; return asset end
	return nil
end

function UI.CreateWeaponGlyph(parent, key)
	local glyph = UI.CreateMenuGlyph(parent, 32, Theme.Surface3, Theme.Sub)
	glyph.Box.Name = "WeaponIcon_" .. tostring(key)
	glyph.Box.Size = UDim2.fromOffset(44, 32)
	local definition = UI.WeaponSilhouettes[key] or UI.WeaponSilhouettes.RIFLE
	local image, readyConnection
	local function nativeSilhouette()
		if not Runtime.Alive or not glyph.Box.Parent or glyph.Fallback or image and image.IsLoaded then return end
		local fallback = Util.New("Frame", {
			Name = "WeaponSilhouette", BackgroundTransparency = 1, BorderSizePixel = 0,
			Position = UDim2.fromOffset(2, 8/3), Size = UDim2.fromOffset(40, 80/3),
		}, glyph.Box)
		glyph.Fallback = fallback
		local themeKey = image and image:GetAttribute("AAPTheme_ImageColor3") or "Sub"
		for index = 1, #definition.Runs, 5 do
			local x, y, width, height, alpha = string.byte(definition.Runs, index, index + 4)
			local part = Util.New("Frame", {
				Position = UDim2.fromScale((x - 33)/60, (y - 33)/40),
				Size = UDim2.fromScale((width - 33)/60, (height - 33)/40),
				BackgroundColor3 = Theme[themeKey], BackgroundTransparency = 1 - (alpha - 33)/4,
				BorderSizePixel = 0,
			}, fallback)
			glyph.Ink[#glyph.Ink + 1] = {part, "BackgroundColor3"}
		end
		UI.SetMenuGlyphColor(glyph, themeKey)
	end
	local asset = UI.GetWeaponIconAsset()
	if asset then
		image = Util.New("ImageLabel", {
			Name = "WeaponArtwork", BackgroundTransparency = 1, BorderSizePixel = 0,
			Position = UDim2.fromOffset(2, 8/3), Size = UDim2.fromOffset(40, 80/3),
			Image = asset, ImageColor3 = Theme.Sub, ImageTransparency = 0, Visible = false,
			ImageRectOffset = Vector2.new(((definition.Index - 1) % 4) * 192, math.floor((definition.Index - 1)/4) * 128),
			ImageRectSize = Vector2.new(192, 128), ScaleType = Enum.ScaleType.Fit,
		}, glyph.Box)
		glyph.Image = image
		glyph.Ink[#glyph.Ink + 1] = {image, "ImageColor3"}
		image:SetAttribute("AAPTheme_ImageColor3", "Sub")
		local function showArtwork()
			if not Runtime.Alive or not glyph.Box.Parent or not image.IsLoaded then return end
			if glyph.Fallback then glyph.Fallback:Destroy(); glyph.Fallback = nil end
			glyph.Ink = {{image, "ImageColor3"}}
			image.Visible = true
			Runtime.Disconnect(readyConnection)
		end
		readyConnection = Runtime.Track(image:GetPropertyChangedSignal("IsLoaded"):Connect(showArtwork))
		showArtwork()
		-- No waiting loop: the menu continues opening while the local image is read.
		task.delay(.15, nativeSilhouette)
	else
		nativeSilhouette()
	end
	return glyph
end

function UI.SetReadableText(label, size, height)
 if not label then return end
 label.TextScaled = false
 label.TextSize = size
 for _, item in ipairs(label:GetChildren()) do
  if item:IsA("UITextSizeConstraint") then item.MinTextSize = size; item.MaxTextSize = size end
 end
 if height then label.Size = UDim2.new(label.Size.X.Scale, label.Size.X.Offset, 0, height) end
end

function UI.CreateArmChoice(parent, label, description, weaponKey, level)
	local card = Util.New("TextButton", {
		BackgroundColor3 = Theme.Card, BackgroundTransparency = .10, BorderSizePixel = 0,
		Text = "", AutoButtonColor = false,
	}, parent)
	Util.Corner(card, 12)
	local control = {Card = card, Stroke = Util.Stroke(card, Theme.BorderSoft, .7, 1)}
	local titleX = weaponKey and 64 or 14
	control.Title = UI.SettingsText(card, label, UDim2.fromOffset(titleX, 11), UDim2.new(1, -(titleX + 32), 0, 20), 10, Theme.Text, true)
	UI.SetReadableText(control.Title, 10)
	control.Description = UI.SettingsText(card, description, UDim2.fromOffset(14, weaponKey and 44 or 34), UDim2.new(1, -28, 0, 26), 9, Theme.Sub)
	control.Description.TextWrapped = true
	control.Description.TextTruncate = Enum.TextTruncate.None
	UI.SetReadableText(control.Description, 9)
	control.Radio = Util.New("Frame", {
		Position = UDim2.new(1, -25, 0, 15), Size = UDim2.fromOffset(12, 12),
		BackgroundColor3 = Theme.Surface3, BackgroundTransparency = .1, BorderSizePixel = 0,
	}, card)
	Util.Corner(control.Radio, 999)
	control.RadioStroke = Util.Stroke(control.Radio, Theme.Muted, .25, 1)
	control.Check = Util.New("Frame", {
		AnchorPoint = Vector2.new(.5, .5), Position = UDim2.fromScale(.5, .5),
		Size = UDim2.fromOffset(6, 6), BackgroundColor3 = Theme.Accent2, BorderSizePixel = 0, Visible = false,
	}, control.Radio)
	Util.Corner(control.Check, 999)
	if weaponKey then
		control.Glyph = UI.CreateWeaponGlyph(card, weaponKey)
		control.Glyph.Box.Position = UDim2.fromOffset(12, 8)
	end
	if level then
		control.LevelDots = {}
		for index = 1, 4 do
			local dot = Util.New("Frame", {
				Position = UDim2.new(0, 14 + (index - 1) * 10, 1, -14), Size = UDim2.fromOffset(5, 5),
				BackgroundColor3 = index <= level and Theme.Accent2 or Theme.Muted,
				BackgroundTransparency = index <= level and .1 or .7, BorderSizePixel = 0,
			}, card)
			Util.Corner(dot, 999)
			control.LevelDots[#control.LevelDots + 1] = dot
		end
	end
	UI.TouchFeedback(card)
	return control
end

function UI.SetArmChoiceSelected(control, selected)
	control.Card.BackgroundColor3 = selected and Theme.CardActive or Theme.Card
	control.Card.BackgroundTransparency = selected and .04 or .14
	control.Stroke.Color = selected and Theme.Accent or Theme.BorderSoft
	control.Stroke.Transparency = selected and .22 or .72
	control.Check.Visible = selected
	control.RadioStroke.Color = selected and Theme.Accent2 or Theme.Muted
	control.Title.TextColor3 = selected and Theme.Accent2 or Theme.Text
	if control.Glyph then
		control.Glyph.Box.BackgroundColor3 = selected and Theme.AccentSoft or Theme.Surface3
		control.Glyph.Box:SetAttribute("AAPTheme_BackgroundColor3", selected and "AccentSoft" or "Surface3")
		UI.SetMenuGlyphColor(control.Glyph, selected and "Accent2" or "Sub")
	end
end

function Pages.BuildAssistant()
	local page = UI.CreatePage("Assistant")
	page:SetAttribute("AAPHideScrollCue", true)
	page.Position = UDim2.fromOffset(3, 3)
	page.Size = UDim2.new(1, -6, 1, -6)
	page.ScrollBarThickness = 5
	local definition = Persistence.DefaultConfig.AimAssistant
	local controls = {WeaponCards = {}, ModeCards = {}, Metrics = {}, Scroll = {}, Active = "WEAPON", Generation = 0}
	local weaponText = {
		RIFLE = {"Rifle", "Uso geral e média distância."},
		SMG = {"SMG", "Submetralhadora para combate próximo."},
		SNIPER = {"Sniper", "Tiros precisos de longa distância."},
		SHOTGUN = {"Escopeta", "Ajuda para confrontos bem próximos."},
		PISTOL = {"Pistola", "Controle em tiros individuais."},
		DMR = {"DMR", "Rifle semiautomático para tiros em sequência."},
		LMG = {"Metralhadora", "Acompanha o alvo durante rajadas longas."},
		PROJECTILE = {"Arco / lançador", "Antecipação para projéteis lentos."},
	}
	local modeText = {
		SOFT = {"Suave", "Correção leve, com movimentos mais suaves."},
		BALANCED = {"Equilibrado", "Correção moderada para uso geral."},
		STRONG = {"Forte", "Correção alta e movimento mais rápido."},
		MAXIMUM = {"Máximo", "Correção máxima e resposta imediata."},
	}
	local toolbar = Util.New("Frame", {
		Name = "AAP_ArmsToolbar", LayoutOrder = -100, Size = UDim2.new(1, 0, 0, 66),
		BackgroundTransparency = 1, Visible = page.Visible,
	}, page)
	controls.Toolbar = toolbar
	controls.StatusChip = UI.SettingsText(toolbar, "", UDim2.new(1, -141, 0, 2), UDim2.fromOffset(104, 22), 9, Theme.Sub, true)
	controls.StatusChip.BackgroundColor3 = Theme.Surface3
	controls.StatusChip.BackgroundTransparency = .2
	controls.StatusChip.TextXAlignment = Enum.TextXAlignment.Center
	Util.Corner(controls.StatusChip, 999)
	controls.Help = UI.CreateHelpButton(toolbar, "Ajustar a mira por arma",
		"Escolha a arma mais parecida com a sua e a intensidade da assistência. Cada toque aplica a combinação imediatamente.\n\nO ajuste inclui FOV, precisão, suavidade, previsão, parte do corpo e checagem de paredes. Para alterar um valor separadamente, use Mira ou Corpo.", UDim2.new(1, 0, 0, -3))
	controls.Summary = UI.SettingsText(toolbar, "", UDim2.fromOffset(2, 1), UDim2.new(1, -152, 0, 24), 11, Theme.Sub)
	UI.SetReadableText(controls.Summary, 11)
	local navigation = Util.New("Frame", {
		Position = UDim2.fromOffset(0, 31), Size = UDim2.new(1, 0, 0, 32),
		BackgroundColor3 = Theme.Surface2, BackgroundTransparency = .10, BorderSizePixel = 0,
	}, toolbar)
	Util.Corner(navigation, 10)
	controls.Tabs = {}
	for index, data in ipairs({{"WEAPON", "Escolher arma"}, {"MODE", "Intensidade"}}) do
		local button = Util.New("TextButton", {
			Position = UDim2.new((index - 1) * .5, 2, 0, 2), Size = UDim2.new(.5, -4, 1, -4),
			BackgroundColor3 = Theme.CardActive, BorderSizePixel = 0, Text = data[2], TextColor3 = Theme.Text,
			Font = Enum.Font.GothamMedium, TextSize = 10, AutoButtonColor = false,
		}, navigation)
		Util.Corner(button, 9)
		controls.Tabs[data[1]] = button
		UI.TouchFeedback(button)
		button.Activated:Connect(function() controls.Show(data[1]) end)
	end
	local function pane(name)
		local holder = Util.New("Frame", {
			Name = name, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
			BackgroundTransparency = 1, Visible = false, LayoutOrder = 10,
		}, page)
		Util.New("UIListLayout", {Padding = UDim.new(0, 9), SortOrder = Enum.SortOrder.LayoutOrder}, holder)
		local grid = Util.New("Frame", {Size = UDim2.new(1, 0, 0, 0), BackgroundTransparency = 1, LayoutOrder = 2}, holder)
		return holder, grid
	end
	controls.WeaponPane, controls.WeaponGrid = pane("AAP_WeaponChoices")
	controls.ModePane, controls.ModeGrid = pane("AAP_IntensityChoices")
	local values, detailsGroup = UI.CreateExpandableGroup(page, "Ver ajustes atuais", "Veja o que está em uso.", false)
	detailsGroup.Shell.LayoutOrder = 20
	controls.DetailsGroup = detailsGroup
	controls.ValuesNote = UI.SettingsText(values, "", UDim2.new(), UDim2.new(1, 0, 0, 31), 8, Theme.Sub)
	controls.ValuesNote.TextWrapped = true
	controls.ValuesNote.LayoutOrder = 1
	local metrics = Util.New("Frame", {Size = UDim2.new(1, 0, 0, 60), BackgroundTransparency = 1, LayoutOrder = 2}, values)
	controls.MetricsHolder = metrics
	for index, data in ipairs({{"FOV", "Área de busca"}, {"Accuracy", "Precisão"}, {"Smoothing", "Suavidade"}}) do
		local box = Util.New("Frame", {
			Position = UDim2.new((index - 1) / 3, 0, 0, 0), Size = UDim2.new(1 / 3, -5, 0, 60),
			BackgroundColor3 = Theme.Card, BackgroundTransparency = .1, BorderSizePixel = 0,
		}, metrics)
		Util.Corner(box, 10)
		local label = UI.SettingsText(box, data[2], UDim2.fromOffset(8, 8), UDim2.new(1, -16, 0, 14), 8, Theme.Sub)
		Util.FitText(label, 7, 8)
		local value = UI.SettingsText(box, "", UDim2.fromOffset(8, 29), UDim2.new(1, -16, 0, 20), 12, Theme.Text, true)
		Util.FitText(value, 8, 13)
		controls.Metrics[data[1]] = value
	end
	controls.BodyDetail = UI.SettingsText(values, "", UDim2.new(), UDim2.new(1, 0, 0, 24), 9, Theme.Sub)
	controls.BodyDetail.LayoutOrder = 3
	controls.PredictionDetail = UI.SettingsText(values, "", UDim2.new(), UDim2.new(1, 0, 0, 24), 9, Theme.Sub)
	controls.PredictionDetail.LayoutOrder = 4
	local function labelFor(data, key, definitions, fallback)
		return data[key] and data[key][1] or definitions[key] and definitions[key].Label or fallback
	end
	function controls.Apply(weaponKey, modeKey)
		if not Runtime.Alive or State.UI.LayoutEditMode or not page.Parent then return false end
		if not Aim.ApplyAssistantPreset(weaponKey, modeKey) then
			UI.Toast("Não foi possível aplicar esta combinação.")
			return false
		end
		for _, name in ipairs({"RefreshAimControls", "RefreshBodyControls", "RefreshEngineControls"}) do
			local refresh = State.UI[name]
			if refresh then refresh() end
		end
		UI.RefreshQuick()
		controls.Refresh()
		UI.Toast("Ajuste aplicado: " .. labelFor(weaponText, weaponKey, definition.Weapons, "Arma") .. " · " .. labelFor(modeText, modeKey, definition.Modes, "Intensidade"))
		return true
	end
	for index, key in ipairs(definition.WeaponOrder) do
		local data = definition.Weapons[key]
		local text = weaponText[key] or {data.Label, data.Description}
		local control = UI.CreateArmChoice(controls.WeaponGrid, text[1], text[2], key)
		controls.WeaponCards[key] = control
		control.Card.LayoutOrder = index
		control.Card.Activated:Connect(function() controls.Apply(key, Config.AimAssistant.Mode) end)
	end
	for index, key in ipairs(definition.ModeOrder) do
		local data = definition.Modes[key]
		local text = modeText[key] or {data.Label, data.Description}
		local control = UI.CreateArmChoice(controls.ModeGrid, text[1], text[2], nil, index)
		controls.ModeCards[key] = control
		control.Card.LayoutOrder = index
		control.Card.Activated:Connect(function() controls.Apply(Config.AimAssistant.Weapon, key) end)
	end
	function controls.Layout()
        local narrowHeader = toolbar.AbsoluteSize.X < 300
        toolbar.Size = UDim2.new(1, 0, 0, narrowHeader and 96 or 66)
        controls.Summary.Size = UDim2.new(1, narrowHeader and -38 or -152, 0, 26)
        controls.StatusChip.Position = narrowHeader and UDim2.fromOffset(2, 31) or UDim2.new(1, -141, 0, 2)
        navigation.Position = UDim2.fromOffset(0, narrowHeader and 61 or 31)
		local function gridLayout(holder, order, cards, mode)
			local width = holder.AbsoluteSize.X
			local columns = width >= 380 and 2 or 1
			if not mode and width >= 720 then columns = 3 end
			local height = math.max(math.floor((mode and 98 or 94) * Config.ControlScale + .5), mode and 86 or 82)
			for index, key in ipairs(order) do
				local column, row = (index - 1) % columns, math.floor((index - 1) / columns)
				local card = cards[key].Card
				card.Position = UDim2.new(column / columns, 10 * column / columns, 0, row * (height + 10))
				card.Size = UDim2.new(1 / columns, -10 * (columns - 1) / columns, 0, height)
			end
			holder.Size = UDim2.new(1, 0, 0, math.ceil(#order / columns) * (height + 10) - 10)
		end
		gridLayout(controls.WeaponGrid, definition.WeaponOrder, controls.WeaponCards, false)
		gridLayout(controls.ModeGrid, definition.ModeOrder, controls.ModeCards, true)
	end
	function controls.Show(key)
		if not Runtime.Alive or not page.Parent then return end
		if key ~= "MODE" then key = "WEAPON" end
		local previous = controls.Active
		controls.Scroll[controls.Active] = page.CanvasPosition.Y
		controls.Active = key
		controls.WeaponPane.Visible = key == "WEAPON"
		controls.ModePane.Visible = key == "MODE"
		for tabKey, button in pairs(controls.Tabs) do
			local selected = tabKey == key
			Util.Tween(button, {BackgroundTransparency = selected and .05 or 1,
				TextColor3 = selected and Theme.Accent2 or Theme.Sub}, 0.16)
		end
		controls.Generation += 1
		local generation = controls.Generation
		controls.Layout()
		if previous ~= key then UI.RevealPage(page, key == "MODE" and 1 or -1) end
		task.defer(function()
			S.RunService.Heartbeat:Wait()
			if Runtime.Alive and page.Parent and generation == controls.Generation then page.CanvasPosition = Vector2.new(0, controls.Scroll[key] or 0) end
		end)
	end
	function controls.Refresh()
		if not Runtime.Alive or not page.Parent then return end
		local assistant = Config.AimAssistant
		local weapon = labelFor(weaponText, assistant.Weapon, definition.Weapons, "Arma")
		local mode = labelFor(modeText, assistant.Mode, definition.Modes, "Intensidade")
		controls.Summary.Text = weapon .. " · " .. mode
		controls.StatusChip.Text = not assistant.Applied and "Não aplicado" or assistant.Customized and "Personalizado" or "Aplicado"
		controls.StatusChip.TextColor3 = assistant.Applied and Theme.Accent2 or Theme.Sub
		controls.StatusChip.BackgroundColor3 = assistant.Applied and Theme.AccentSoft or Theme.Surface3
		controls.ValuesNote.Text = assistant.Applied and assistant.Customized and "Você alterou valores depois de aplicar a combinação."
			or assistant.Applied and "Valores aplicados à mira agora." or "Valores atuais. Escolha uma arma para aplicar a combinação."
		for key, control in pairs(controls.WeaponCards) do UI.SetArmChoiceSelected(control, key == assistant.Weapon) end
		for key, control in pairs(controls.ModeCards) do UI.SetArmChoiceSelected(control, key == assistant.Mode) end
		controls.Metrics.FOV.Text = tostring(math.floor(Config.FOV + .5)) .. " px"
		controls.Metrics.Accuracy.Text = tostring(math.floor(Config.Accuracy + .5)) .. "%"
		controls.Metrics.Smoothing.Text = tostring(math.floor(Config.Smoothing + .5)) .. "%"
		local region = BodyRegions[Config.PrimaryBodyRegion]
		controls.BodyDetail.Text = "Parte do corpo: " .. (region and region.Label or "Padrão")
		controls.PredictionDetail.Text = "Previsão: " .. (not Config.Prediction and "desativada" or Config.PredictionMode == "MANUAL" and "manual" or "automática")
		for tabKey, button in pairs(controls.Tabs) do
			button.TextColor3 = tabKey == controls.Active and Theme.Accent2 or Theme.Sub
		end
		controls.Layout()
	end
	local lastWidth = -1
	page:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
		if page.AbsoluteSize.X ~= lastWidth then lastWidth = page.AbsoluteSize.X; controls.Layout() end
	end)
	page:GetPropertyChangedSignal("Visible"):Connect(function()
		toolbar.Visible = page.Visible
		if page.Visible then controls.Refresh() end
	end)
	State.UI.ArmsControls = controls
	State.UI.RefreshAssistantControls = controls.Refresh
	controls.Show("WEAPON")
	controls.Refresh()
	return page
end

UI.BodyPartLabels = {
	Head = "Cabeça", Torso = "Tronco", UpperTorso = "Tronco superior", LowerTorso = "Tronco inferior",
	["Left Arm"] = "Braço esquerdo", ["Right Arm"] = "Braço direito",
	LeftUpperArm = "Braço esquerdo", RightUpperArm = "Braço direito",
	LeftLowerArm = "Antebraço esquerdo", RightLowerArm = "Antebraço direito",
	LeftHand = "Mão esquerda", RightHand = "Mão direita",
	["Left Leg"] = "Perna esquerda", ["Right Leg"] = "Perna direita",
	LeftUpperLeg = "Coxa esquerda", RightUpperLeg = "Coxa direita",
	LeftLowerLeg = "Perna esquerda", RightLowerLeg = "Perna direita",
	LeftFoot = "Pé esquerdo", RightFoot = "Pé direito",
}
UI.BodyRegionLabels = {Head = "Cabeça", Torso = "Tronco", LeftArm = "Braço esquerdo", RightArm = "Braço direito",
	LeftLeg = "Perna esquerda", RightLeg = "Perna direita"}

function UI.BodyPartLabel(partName)
	return UI.BodyPartLabels[partName] or tostring(partName or "Parte do corpo")
end

function UI.CreateBodyWorkspace(page, controls)
	page:SetAttribute("AAPHideScrollCue", true)
	local header = Util.New("Frame", {Name = "AAP_BodyHeader", Size = UDim2.new(1, 0, 0, 58),
		BackgroundTransparency = 1, LayoutOrder = -100}, page)
	UI.AimText(header, "Corpo", UDim2.fromOffset(2, 2), UDim2.new(1, -42, 0, 24), 16, Theme.Text, true)
	UI.AimText(header, "Escolha onde a mira deve começar.", UDim2.fromOffset(2, 32), UDim2.new(1, -42, 0, 16), 9, Theme.Sub)
	UI.CreateHelpButton(header, "Sua parte principal",
		"Toque no boneco ou escolha uma parte pela lista. R6 tem seis partes; R15 separa braços, pernas e tronco em mais segmentos. A escolha também aparece na aba Mira. Se o jogador usar outro modelo, a mira procura a região equivalente.", UDim2.new(1, 0, 0, 10))
	local panel = Util.New("Frame", {Name = "AAP_BodyWorkspace", Size = UDim2.new(1, 0, 0, 296),
		BackgroundColor3 = Theme.Card, BackgroundTransparency = .12, BorderSizePixel = 0, LayoutOrder = 0}, page)
	Util.Corner(panel, 14); Util.Stroke(panel, Theme.BorderSoft, .55, 1)
	UI.AimText(panel, "Modelo", UDim2.fromOffset(12, 14), UDim2.new(1, -142, 0, 18), 10, Theme.Sub)
	local selector = Util.New("Frame", {AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -10, 0, 8),
		Size = UDim2.fromOffset(112, 32), BackgroundColor3 = Theme.Surface2, BorderSizePixel = 0}, panel)
	Util.Corner(selector, 10); Util.Stroke(selector, Theme.BorderSoft, .68, 1)
	for index, rigName in ipairs({"R6", "R15"}) do
		local button = Util.New("TextButton", {Position = UDim2.fromOffset(3 + (index - 1) * 55, 3),
			Size = UDim2.fromOffset(51, 26), BackgroundColor3 = Theme.Card, BackgroundTransparency = .08,
			BorderSizePixel = 0, Text = rigName, TextColor3 = Theme.Sub, Font = Enum.Font.GothamMedium,
			TextSize = 10, AutoButtonColor = false}, selector)
		Util.Corner(button, 8); UI.TouchFeedback(button)
		controls.RigButtons[rigName] = {Button = button, Stroke = Util.Stroke(button, Theme.BorderSoft, .7, 1)}
	end
	local stage = Util.New("Frame", {Name = "AAP_BodyStage", BackgroundColor3 = Theme.Surface2,
		BackgroundTransparency = .04, BorderSizePixel = 0}, panel)
	Util.Corner(stage, 12)
	local viewport = Util.New("ViewportFrame", {Position = UDim2.fromOffset(2, 2), Size = UDim2.new(1, -4, 1, -35),
		BackgroundTransparency = 1, BorderSizePixel = 0, Ambient = Color3.fromRGB(215, 215, 220),
		LightColor = Color3.fromRGB(255, 255, 255), LightDirection = Vector3.new(-.5, -1, -.6),
		ClipsDescendants = true}, stage)
	local world = Util.New("WorldModel", {}, viewport)
	local camera = Instance.new("Camera"); camera.Parent = viewport; viewport.CurrentCamera = camera
	local previewHint = UI.AimText(stage, "Carregando boneco…", UDim2.new(0, 8, 1, -30), UDim2.new(1, -16, 0, 24), 8, Theme.Sub)
	previewHint.TextWrapped = true; previewHint.TextXAlignment = Enum.TextXAlignment.Center
	local detail = Util.New("Frame", {Name = "AAP_BodySelection", BackgroundTransparency = 1}, panel)
	UI.AimText(detail, "Parte principal", UDim2.fromOffset(2, 3), UDim2.new(1, -4, 0, 18), 10, Theme.Text, true)
	local partButton = Util.New("TextButton", {Position = UDim2.fromOffset(0, 29), Size = UDim2.new(1, 0, 0, 38),
		BackgroundColor3 = Theme.CardActive, BackgroundTransparency = .06, BorderSizePixel = 0,
		Text = "", AutoButtonColor = false}, detail)
	Util.Corner(partButton, 10); Util.Stroke(partButton, Theme.AccentSoft, .45, 1); UI.TouchFeedback(partButton)
	controls.Title = UI.AimText(partButton, "", UDim2.new(), UDim2.fromScale(1, 1), 11, Theme.Accent2, true)
	controls.PartPicker = {Card = partButton, Value = controls.Title}
	controls.Status = UI.AimText(detail, "", UDim2.fromOffset(2, 75), UDim2.new(1, -4, 0, 16), 9, Theme.Sub)
	controls.SyncStatus = UI.AimText(detail, "Usada também na aba Mira.", UDim2.fromOffset(2, 96), UDim2.new(1, -4, 0, 16), 9, Theme.Sub)
	controls.RegionEnabled = UI.CreateToggle(detail, "Região principal", "Sempre disponível.", {Organizable = false, Scalable = false})
	local primary = controls.RegionEnabled
	primary.Card.Position = UDim2.fromOffset(0, 122); primary.Card.Size = UDim2.new(1, 0, 0, 38)
	primary.Title.Position = UDim2.fromOffset(10, 9); primary.Title.Size = UDim2.new(1, -63, 0, 18)
	UI.SetReadableText(primary.Title, 9); primary.Switch.Visible = false; primary.Description.Visible = false
	controls.RegionChip = UI.AimText(primary.Card, "Ativa", UDim2.new(1, -51, 0, 10), UDim2.fromOffset(42, 18), 9, Theme.Accent2)
	controls.RuleSummary = UI.AimText(detail, "", UDim2.fromOffset(2, 169), UDim2.new(1, -4, 0, 32), 9, Theme.Sub)
	controls.RuleSummary.TextWrapped = true
	controls.Recenter = Util.New("TextButton", {Position = UDim2.new(0, 0, 1, -32), Size = UDim2.new(1, 0, 0, 30),
		BackgroundColor3 = Theme.Surface3, BackgroundTransparency = .12, BorderSizePixel = 0,
		Text = "Voltar à frente", TextColor3 = Theme.Sub, Font = Enum.Font.GothamMedium, TextSize = 9,
		AutoButtonColor = false}, detail)
	Util.Corner(controls.Recenter, 9); UI.TouchFeedback(controls.Recenter)
	controls.Reload = Util.New("TextButton", {AnchorPoint = Vector2.new(.5, .5), Position = UDim2.fromScale(.5, .5),
		Size = UDim2.fromOffset(116, 32), BackgroundColor3 = Theme.Surface3, BorderSizePixel = 0,
		Text = "Tentar novamente", TextColor3 = Theme.Text, Font = Enum.Font.GothamMedium,
		TextSize = 9, AutoButtonColor = false, Visible = false, ZIndex = 14}, viewport)
	Util.Corner(controls.Reload, 10); UI.TouchFeedback(controls.Reload)
	controls.Panel, controls.Stage, controls.Viewport, controls.Detail = panel, stage, viewport, detail
	controls.PreviewHint = previewHint
	return panel, viewport, world, camera, previewHint
end

function UI.StyleBodyControl(control)
	local slot = control.Record and control.Record.Card or control.Card
	if control.Track then
		UI.StyleAimControl(control)
		control.Title.Text = "Preferência da região"
		control.Description.Size = UDim2.new(1, control.Help and -62 or -24, 0, 24)
		if control.Help then control.Help.Position = UDim2.new(1, -10, 0, 34) end
	else
		local height = math.max(88, math.floor(96 * Config.ControlScale + .5))
		slot.Size = UDim2.new(slot.Size.X.Scale, slot.Size.X.Offset, 0, height)
		control.Title.Position = UDim2.fromOffset(12, 8)
		control.Title.Size = UDim2.new(1, control.Help and -118 or -82, 0, 30)
		control.Title.TextWrapped = true; control.Title.TextYAlignment = Enum.TextYAlignment.Center
		UI.SetReadableText(control.Title, 11)
		control.Description.Position = UDim2.fromOffset(12, 46)
		control.Description.Size = UDim2.new(1, -24, 0, 30)
		control.Description.TextWrapped = true; control.Description.TextTruncate = Enum.TextTruncate.None
		UI.SetReadableText(control.Description, 9)
		control.Switch.Position = UDim2.new(1, -12, 0, 10)
		if control.Help then control.Help.Position = UDim2.new(1, -66, 0, 10) end
		for _, entry in ipairs(UI.ScalableControls) do
			if entry.Card == slot then entry.BaseHeight = 96; entry.MinimumHeight = 88; break end
		end
	end
	if control.Record then control.Record.OriginalSize = slot.Size end
	return slot
end

function UI.LayoutBodyWorkspace(controls)
	local panel = controls.Panel
	if not Runtime.Alive or not panel.Parent then return end
	local wide = panel.AbsoluteSize.X >= 390
	local narrow = panel.AbsoluteSize.X < 285
	panel.Size = UDim2.new(1, 0, 0, wide and 296 or narrow and 456 or 400)
	controls.Stage.Position = UDim2.fromOffset(10, 48)
	controls.Stage.Size = wide and UDim2.new(.45, -14, 1, -58) or UDim2.new(1, -20, 0, narrow and 186 or 196)
	controls.Detail.Position = wide and UDim2.new(.45, 6, 0, 48) or UDim2.fromOffset(12, narrow and 246 or 256)
	controls.Detail.Size = wide and UDim2.new(.55, -18, 1, -58) or UDim2.new(1, -24, 1, narrow and -256 or -266)
	controls.SyncStatus.Visible = wide
	controls.Status.Position = wide and UDim2.fromOffset(2, 75) or UDim2.fromOffset(2, 71)
	controls.RegionEnabled.Card.Position = wide and UDim2.fromOffset(0, 122) or UDim2.fromOffset(0, 94)
	controls.RegionEnabled.Card.Size = UDim2.new(wide and 1 or .52, wide and 0 or -4, 0, 38)
	controls.RuleSummary.Visible = wide
	controls.RuleSummary.Position = wide and UDim2.fromOffset(2, 169) or UDim2.fromOffset(2, 138)
	controls.Recenter.Position = wide and UDim2.new(0, 0, 1, -32) or UDim2.new(.52, 4, 0, 98)
	controls.Recenter.Size = wide and UDim2.new(1, 0, 0, 30) or UDim2.new(.48, -4, 0, 30)
	if narrow then
		controls.RegionEnabled.Card.Size = UDim2.new(1, 0, 0, 38)
		controls.Recenter.Position = UDim2.fromOffset(0, 146)
		controls.Recenter.Size = UDim2.new(1, 0, 0, 30)
	end
	if controls.PartPicker.RefreshChoiceIndicator then controls.PartPicker.RefreshChoiceIndicator() end
	for _, name in ipairs({"Exact", "Strict", "MultiPoint", "Fallback", "LongRange", "Weight"}) do
		if controls[name] then UI.StyleBodyControl(controls[name]) end
	end
	for _, control in pairs(controls.AllowedRegions or {}) do UI.StyleBodyControl(control) end
end

function UI.RefreshBodyWorkspace(controls)
	local region = UI.BodyRegionLabels[controls.SelectedRegion] or "Região"
	controls.Title.Text = UI.BodyPartLabel(controls.SelectedPartName)
	controls.Status.Text = "Região: " .. region
	controls.SyncStatus.Text = "Usada também na aba Mira."
	controls.RegionChip.Text = "Ativa"
	controls.RegionEnabled.Title.TextTransparency = 0
	controls.RuleSummary.Text = Config.StrictBodyRegion
		and (Config.BodyFallback and "Prioriza esta parte. Se precisar, tenta as regiões liberadas." or "Usa somente esta parte enquanto estiver disponível.")
		or "Compara as regiões liberadas e escolhe o melhor ponto."
	controls.Weight.Description.Text = Config.StrictBodyRegion
		and "A prioridade vem antes deste peso."
		or "Maior dá preferência a esta região."
	controls.Fallback.Description.Text = Config.StrictBodyRegion
		and "Se a principal não servir, procura nas regiões liberadas."
		or "Com a prioridade desligada, já compara as regiões liberadas."
	controls.LongRange.Description.Text = controls.SelectedRegion == "Head" and Config.ExactBodyAim
		and "Evita mirar baixo na cabeça de longe."
		or "Só atua com Cabeça e Mirar no centro ligados."
	UI.LayoutBodyWorkspace(controls)
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

	local panel, viewport, world, camera, previewHint = UI.CreateBodyWorkspace(page, controls)

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
				PartLabels[entry.Name] = UI.BodyPartLabel(entry.Name)
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
				verticalDistance * 1.32,
				horizontalDistance * 1.32,
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

		controls.Reload.Visible = false
		previewHint.Text = "Carregando boneco…"
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
			clearWorld()
			controls.Reload.Visible = true
			previewHint.Text =
				"Prévia indisponível. Use a lista."
			previewHint.TextColor3 = Theme.Warning
			return
		end

		clearWorld()
		previewHint.Text = "Toque para escolher · Arraste para girar"
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
			if not Runtime.Alive or State.UI.LayoutEditMode then return end
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
		if not Runtime.Alive or not page.Visible or State.UI.LayoutEditMode or State.UI.ActiveChoiceMenu then return end
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

		if shouldSelect and Runtime.Alive and page.Visible and not State.UI.ActiveChoiceMenu then
			selectPartAt(position)
		end
	end))


	local basic = UI.Stack(page)
	basic.LayoutOrder = 1
	UI.AimText(basic, "Comportamento", UDim2.new(), UDim2.new(1, 0, 0, 26), 11, Theme.Text, true)
	controls.Exact = UI.CreateToggle(basic, "Manter no centro", "Mantém a mira no centro da parte escolhida.")
	controls.Exact.Title.Text = "Mirar no centro"
	controls.Strict = UI.CreateToggle(basic, "Priorizar a parte escolhida", "Tenta sua parte principal antes de procurar outra.")
	controls.Strict.Title.Text = "Priorizar esta parte"
	local options, advanced = UI.CreateExpandableGroup(page, "Ajustes avançados", "Pontos, regiões e distância.", false)
	controls.Advanced = advanced
	advanced.Shell.LayoutOrder = 2
	controls.MultiPoint = UI.CreateToggle(options, "Buscar outro ponto visível", "Se o centro estiver coberto, tenta outro ponto da mesma parte.")
	controls.MultiPoint.Title.Text = "Buscar ponto visível"
	controls.Fallback = UI.CreateToggle(options, "Tentar outra parte", "Se a principal não servir, procura nas regiões liberadas.", {
		Help = "Com Priorizar esta parte ligado, a mira começa pela parte escolhida. Se não conseguir usá-la, esta opção permite tentar as regiões que você liberou abaixo.",
	})
	controls.Fallback.Title.Text = "Usar outra parte"
	UI.AimText(options, "Regiões liberadas", UDim2.new(), UDim2.new(1, 0, 0, 28), 11, Theme.Text, true)
	controls.AllowedRegions = {}
	for _, regionName in ipairs(BodyRegionOrder) do
		local selectedRegion = regionName
		local control = UI.CreateToggle(options, UI.BodyRegionLabels[regionName], "Disponível para buscar outro ponto.",
			{Id = "body.allowed_region." .. selectedRegion})
		controls.AllowedRegions[selectedRegion] = control
		control.Card.MouseButton1Click:Connect(function()
			if not Runtime.Alive or State.UI.LayoutEditMode then return end
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
	controls.Weight = UI.CreateSlider(options, "Preferência desta região", 0, 100,
		Config.BodyRegionWeights[controls.SelectedRegion] or 100, "%", function(value)
			Config.BodyRegionWeights[controls.SelectedRegion] = math.floor(value + .5)
			Aim.MarkAssistantCustomized()
		end, {Organizable = false, Scalable = false, Description = "Maior dá preferência a esta região.",
			Help = "Este peso é da região que você escolheu no boneco ou na lista. Ele ajuda a comparar os pontos disponíveis. Com Priorizar esta parte ligado, a parte principal vem antes do peso."})
	controls.LongRange = UI.CreateToggle(options, "Corrigir altura da cabeça", "Evita mirar baixo na cabeça de longe.", {
		Help = "Só atua quando Cabeça está escolhida e Mirar no centro está ligado. Compensar distância, na aba Mira, controla a força geral do movimento.",
	})
	controls.LongRange.Title.Text = "Corrigir cabeça"
	for index, control in ipairs({controls.Exact, controls.Strict}) do
		local slot = UI.StyleBodyControl(control); slot.LayoutOrder = index
	end
	local order = {controls.MultiPoint, controls.Fallback}
	for _, regionName in ipairs(BodyRegionOrder) do order[#order + 1] = controls.AllowedRegions[regionName] end
	order[#order + 1] = controls.Weight; order[#order + 1] = controls.LongRange
	for index, control in ipairs(order) do
		local slot = UI.StyleBodyControl(control); slot.LayoutOrder = index * 10
	end
	for _, child in ipairs(options:GetChildren()) do
		if child:IsA("TextLabel") then child.LayoutOrder = 25 end
	end
	UI.BindChoiceMenu(controls.PartPicker, "Parte principal", function()
		local choices = {}
		local profile = BodyRigProfiles[controls.RigMode] or BodyRigProfiles.R15
		for _, entry in ipairs(profile.Parts) do
			choices[#choices + 1] = {Value = entry.Name, Label = UI.BodyPartLabel(entry.Name)}
		end
		return choices
	end, function() return Config.PrimaryBodyPartName end, function(value)
		UI.SetPrimaryBodyPart(value, {RigMode = controls.RigMode, Reason = "Parte escolhida pela lista"})
	end)

	function controls.Refresh()
		if not Runtime.Alive or not page.Parent then return end
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
			"A região principal fica sempre disponível.")
		for regionName, control in pairs(controls.AllowedRegions) do
			UI.SetToggle(control, Config.BodyRegionEnabled[regionName] == true)
			UI.SetControlAvailable(control, regionName ~= Config.PrimaryBodyRegion,
				"A região principal fica sempre disponível.")
		end

		UI.RefreshBodyWorkspace(controls)
		updatePreviewOverlay()
	end

	controls.RegionEnabled.Card.MouseButton1Click:
		Connect(function()
			local region =
				controls.SelectedRegion

			Config.BodyRegionEnabled =
				Config.BodyRegionEnabled or {}

			if Config.PrimaryBodyRegion == region then
				UI.Toast("A região principal fica sempre disponível. Veja as outras regiões nos ajustes avançados.")
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
		if not Runtime.Alive or State.UI.LayoutEditMode then return end
		Config.ExactBodyAim = not Config.ExactBodyAim
		Aim.MarkAssistantCustomized()
		Aim.ClearCurrentTarget("Modo de precisão alterado")
		controls.Refresh()
	end)

	controls.Strict.Card.MouseButton1Click:Connect(function()
		if not Runtime.Alive or State.UI.LayoutEditMode then return end
		Config.StrictBodyRegion = not Config.StrictBodyRegion
		Aim.MarkAssistantCustomized()
		Aim.ClearCurrentTarget("Prioridade corporal alterada")
		controls.Refresh()
	end)

	controls.MultiPoint.Card.MouseButton1Click:Connect(function()
		if not Runtime.Alive or State.UI.LayoutEditMode then return end
		Config.MultiPointBodyAim = not Config.MultiPointBodyAim
		Aim.MarkAssistantCustomized()
		Aim.ClearCurrentTarget("Pontos de mira alterados")
		controls.Refresh()
	end)

	controls.Fallback.Card.MouseButton1Click:Connect(function()
		if not Runtime.Alive or State.UI.LayoutEditMode then return end
		Config.BodyFallback = not Config.BodyFallback
		Aim.MarkAssistantCustomized()
		Aim.ClearCurrentTarget("Tentativa em outra parte foi alterada")
		controls.Refresh()
	end)

	controls.LongRange.Card.MouseButton1Click:Connect(function()
		if not Runtime.Alive or State.UI.LayoutEditMode then return end
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


	controls.Recenter.Activated:Connect(function()
		if not Runtime.Alive or State.UI.LayoutEditMode then return end
		Preview.DragInput, Preview.DragStart, Preview.DragMoved = nil, nil, false
		Preview.Rotation = 180
		if Preview.Model then placeModelFront(Preview.Model); schedulePreviewFrame() end
	end)
	controls.Reload.Activated:Connect(function()
		if not Runtime.Alive or State.UI.LayoutEditMode or not controls.Reload.Visible then return end
		controls.Reload.Visible = false
		task.defer(loadCharacter)
	end)
	local lastWidth = -1
	panel:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
		if panel.AbsoluteSize.X ~= lastWidth then
			lastWidth = panel.AbsoluteSize.X
			UI.LayoutBodyWorkspace(controls)
			schedulePreviewFrame()
		end
	end)
	page:GetPropertyChangedSignal("Visible"):Connect(function()
		if page.Visible then controls.Refresh()
		else Preview.DragInput, Preview.DragStart, Preview.DragMoved = nil, nil, false end
	end)
	State.UI.BodyControls = controls
	controls.Preview = Preview

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

	if kind == "MOBILE" or kind == "ORDER" then
		local box = Util.New("Frame", {
			Size = UDim2.fromOffset(size, size), BackgroundColor3 = Theme.AccentSoft,
			BackgroundTransparency = .35, BorderSizePixel = 0,
		}, parent)
		Util.Corner(box, 10)
		local function part(x, y, width, height, hollow)
			local shape = Util.New("Frame", {
				Position = UDim2.fromScale(x, y), Size = UDim2.fromScale(width, height),
				BackgroundColor3 = Theme.Accent2, BackgroundTransparency = hollow and 1 or 0,
				BorderSizePixel = 0,
			}, box)
			Util.Corner(shape, 999)
			if hollow then Util.Stroke(shape, Theme.Accent2, .12, 1) end
		end
		if kind == "MOBILE" then
			part(.33, .18, .34, .64, true); part(.43, .69, .14, .04)
		else
			part(.25, .29, .5, .07); part(.25, .47, .36, .07); part(.25, .65, .44, .07)
		end
		return box
	end
	local glyph, draw = UI.CreateMenuGlyph(parent, size, Theme.AccentSoft, Theme.Accent2)
	glyph.Box.Name = "SettingsIcon_" .. kind
	glyph.Box.BackgroundTransparency = .35
	if kind == "MENU" then
		-- Window: appearance and arrangement of the interface.
		draw.Outline(6, 7, 20, 18, 3)
		draw.Line(7, 13, 25, 13)
		draw.Line(13, 14, 13, 24)
	else
		-- Saved settings: a disk with a distinct label, never an oval.
		draw.Outline(7, 5, 18, 22, 2.8)
		draw.Line(12, 6, 12, 12, 1.6)
		draw.Line(12, 12, 20, 12, 1.6)
		draw.Line(20, 12, 20, 6, 1.6)
		draw.Outline(11, 18, 10, 6, 1)
	end
	return glyph.Box
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
	Util.New("UIListLayout", {Padding = UDim.new(0, 10), SortOrder = Enum.SortOrder.LayoutOrder}, content)
	if id then UI.RegisterOrganizerContainer(content, id) end
	return content, shell
end

function UI.StyleSettingsControl(control)
	local card = control.Card
	local cycle = typeof(control.Value) == "Instance"
	local baseHeight = cycle and 112 or control.Switch and 96 or 122
	local minimumHeight = cycle and 98 or control.Switch and 84 or 110
	local slot = control.Record and control.Record.Card or card
	for _, entry in ipairs(UI.ScalableControls) do
		if entry.Card == slot then
			entry.BaseHeight = baseHeight
			entry.MinimumHeight = minimumHeight
			break
		end
	end
	slot.Size = UDim2.new(slot.Size.X.Scale, slot.Size.X.Offset, 0,
		math.max(minimumHeight, math.floor(baseHeight * Config.ControlScale + .5)))
	if control.Record then control.Record.OriginalSize = slot.Size end
	card.BackgroundTransparency = 0.12
	control.Title.Font = Enum.Font.GothamMedium
	UI.SetReadableText(control.Title, 10, 20)
	if cycle then
		control.Title.Position = UDim2.fromOffset(14, 8)
		control.Title.Size = UDim2.new(1, control.Help and -54 or -28, 0, 20)
		control.Description.Position = UDim2.fromOffset(14, 32)
		control.Description.Size = UDim2.new(1, -28, 0, 26)
		control.Value.AnchorPoint = Vector2.new(0, 1)
		control.Value.Position = UDim2.new(0, 14, 1, -8)
		control.Value.Size = UDim2.new(1, -28, 0, 26)
		control.Value.BackgroundColor3 = Theme.Surface3
		control.Value.TextColor3 = Theme.Accent2
		UI.SetReadableText(control.Value, 10)
		if control.Help then control.Help.Position = UDim2.new(1, -10, 0, 3) end
	elseif control.Switch then
		control.Title.Size = UDim2.new(1, control.Help and -116 or -86, 0, 28)
		control.Title.TextWrapped = true
		control.Description.Position = UDim2.fromOffset(14, 40)
		control.Description.Size = UDim2.new(1, -28, 0, 28)
	else
		control.Title.Position = UDim2.fromOffset(14, 6)
		control.Title.Size = UDim2.new(1, control.Help and -128 or -96, 0, 30)
		control.Title.TextWrapped = true
		control.Description.Position = UDim2.fromOffset(14, 42)
		control.Description.Size = UDim2.new(1, -28, 0, 26)
		control.Label.Position = UDim2.new(1, -14, 0, 6)
		control.Label.Size = UDim2.fromOffset(66, 26)
		if control.Help then control.Help.Position = UDim2.new(1, -84, 0, 5) end
	end
	UI.SetReadableText(control.Description, 9)
	control.Description.TextWrapped = true
end

function UI.CreateSettingsWorkspace(page)
	local view = {Page = page, Categories = {}, Tiles = {}, Entries = {}, Scroll = {}, Active = "HOME", Display = "HOME", Generation = 0, LastSearchText = ""}
	page:SetAttribute("AAPHideScrollCue", true)
	page.Position = UDim2.fromOffset(3, 3)
	page.Size = UDim2.new(1, -6, 1, -6)
	page.ScrollBarThickness = 5
	local toolbar = Util.New("Frame", {
		Name = "AAP_SettingsToolbar", LayoutOrder = -100,
		Size = UDim2.new(1, 0, 0, 68), BackgroundTransparency = 1,
		Visible = page.Visible,
	}, page)
	view.Toolbar = toolbar
	view.Back = Util.New("TextButton", {
		Size = UDim2.fromOffset(66, 28), BackgroundColor3 = Theme.Surface3, BackgroundTransparency = .25,
		BorderSizePixel = 0, Text = "‹  Início", TextColor3 = Theme.Sub, Font = Enum.Font.GothamMedium,
		TextSize = 10, AutoButtonColor = false, Visible = false,
	}, toolbar)
	Util.Corner(view.Back, 10)
	UI.TouchFeedback(view.Back)
	view.Title = UI.SettingsText(toolbar, "Configurações", UDim2.fromOffset(2, 2), UDim2.new(1, -4, 0, 24), 13, Theme.Text, true)
	UI.SetReadableText(view.Title, 12)
	local searchBox = Util.New("Frame", {
		Position = UDim2.fromOffset(0, 34), Size = UDim2.new(1, 0, 0, 32),
		BackgroundColor3 = Theme.Surface3, BackgroundTransparency = .3, BorderSizePixel = 0,
	}, toolbar)
	Util.Corner(searchBox, 10)
	Util.Stroke(searchBox, Theme.BorderSoft, .65, 1)
	view.Search = Util.New("TextBox", {
		Position = UDim2.fromOffset(12, 0), Size = UDim2.new(1, -46, 1, 0), BackgroundTransparency = 1,
		Text = "", PlaceholderText = "Buscar ajuste...", PlaceholderColor3 = Theme.Sub,
		TextColor3 = Theme.Text, Font = Enum.Font.Gotham, TextSize = 10,
		TextXAlignment = Enum.TextXAlignment.Left, ClearTextOnFocus = false, MultiLine = false,
	}, searchBox)
	view.Clear = Util.New("TextButton", {
		Position = UDim2.new(1, -32, 0, 0), Size = UDim2.fromOffset(32, 32), BackgroundTransparency = 1,
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
		BackgroundColor3 = Theme.CardActive, BackgroundTransparency = .13, BorderSizePixel = 0, LayoutOrder = 20,
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
		UI.SetReadableText(title, 11)
		local detail = UI.SettingsText(card, definition.Detail, UDim2.fromOffset(12, 44), UDim2.new(1, -24, 0, 24), 9, Theme.Sub)
        detail.TextWrapped = true
        detail.TextTruncate = Enum.TextTruncate.None
        UI.SetReadableText(detail, 9)
		local state = UI.SettingsText(card, "", UDim2.fromOffset(12, 76), UDim2.new(1, -40, 0, 16), 9, Theme.Accent2)
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
		local previous = view.Display
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
		if previous ~= key then UI.RevealPage(page, key == "HOME" and -1 or 1) end
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
		local columns = tiles.AbsoluteSize.X >= 400 and 2 or 1
		for index, definition in ipairs(definitions) do
			local column, row = (index - 1) % columns, math.floor((index - 1) / columns)
			local card = view.Tiles[definition.Key].Card
			card.Position = UDim2.new(column / columns, column == 0 and 0 or 5, 0, row * 110)
			card.Size = UDim2.new(1 / columns, columns == 1 and 0 or -5, 0, 100)
		end
		tiles.Size = UDim2.new(1, 0, 0, math.ceil(#definitions / columns) * 110 - 10)
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

	local aimAdvancedHeading = UI.Section(
		aimCategory,
		"MOVIMENTO E CORREÇÃO",
		"Use estes controles quando quiser ajustar a mira além dos perfis prontos."
	)

	aimAdvancedHeading.Visible = false
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
			"Muda só a resposta da arma. Para configurar tudo de uma vez, use Armas.",
			{
				Help = "Este atalho altera apenas o comportamento usado para acompanhar disparos. A aba Armas também ajusta FOV, precisão, suavidade e parte do corpo.",
			}
		)

	for _, control in ipairs({controls.Horizontal, controls.Vertical, controls.Distance, controls.Curve, controls.Profile}) do
		UI.StyleAimControl(control)
	end
	controls.Distance.Title.Text = "Compensar distância"

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

function UI.StyleESPControl(control)
	UI.StyleAimControl(control)
	local height = control.Track and 108 or control.Value and 102 or 86
	local minimum = control.Track and 100 or control.Value and 94 or 80
	local scaled = math.max(minimum, math.floor(height * Config.ControlScale + .5))
	control.Card.Size = UDim2.new(control.Card.Size.X.Scale,control.Card.Size.X.Offset,0,scaled)
	for _, entry in ipairs(UI.ScalableControls) do
		if entry.Card == control.Card then entry.BaseHeight,entry.MinimumHeight = height,minimum; break end
	end
	control.Title.TextWrapped = true
	if control.Switch then
		control.Title.Size = UDim2.new(1,-82,0,24)
		control.Description.Position = UDim2.fromOffset(12,37)
		control.Description.Size = UDim2.new(1,-24,0,32)
	end
	return scaled
end

function Pages.BuildESP()
	local page = UI.CreatePage("ESP")
	page:SetAttribute("AAPHideScrollCue",true)
	local controls = {Items = {}, Groups = {}, Panes = {}, Tabs = {}, Scroll = {}, Active = "VISUAL", Generation = 0}
	local header = Util.New("Frame", {Name = "ESPHeader", Size = UDim2.new(1,0,0,78),
		BackgroundTransparency = 1, LayoutOrder = -100}, page)
	UI.AimText(header,"Visão dos jogadores",UDim2.fromOffset(2,3),UDim2.new(1,-116,0,22),12,Theme.Text,true)
	controls.Power = Util.New("TextButton", {AnchorPoint = Vector2.new(1,0), Position = UDim2.new(1,-2,0,0),
		Size = UDim2.fromOffset(105,32), BackgroundColor3 = Theme.CardActive, BorderSizePixel = 0,
		Text = "", TextColor3 = Theme.Accent2, Font = Enum.Font.GothamBold, TextSize = 10, AutoButtonColor = false},header)
	Util.Corner(controls.Power,10); UI.TouchFeedback(controls.Power)
	local navigation = Util.New("Frame",{Position=UDim2.fromOffset(0,40),Size=UDim2.new(1,0,0,36),
		BackgroundColor3=Theme.Surface2,BackgroundTransparency=.1,BorderSizePixel=0},header)
	Util.Corner(navigation,10)
	for index,data in ipairs({{"VISUAL","Visual"},{"2D","ESP 2D"},{"FILTERS","Filtros"}}) do
		local key = data[1]
		local button = Util.New("TextButton",{Position=UDim2.new((index-1)/3,2,0,2),Size=UDim2.new(1/3,-4,1,-4),
			BackgroundColor3=Theme.CardActive,BorderSizePixel=0,Text=data[2],TextColor3=Theme.Sub,
			Font=Enum.Font.GothamMedium,TextSize=10,AutoButtonColor=false},navigation)
		Util.Corner(button,8); UI.TouchFeedback(button); controls.Tabs[key]=button
		button.Activated:Connect(function() controls.Show(key) end)
		local pane = Util.New("Frame",{Name="ESP_"..key,Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y,
			BackgroundTransparency=1,Visible=false,LayoutOrder=10},page)
		Util.New("UIListLayout",{Padding=UDim.new(0,12),SortOrder=Enum.SortOrder.LayoutOrder},pane)
		controls.Panes[key]=pane
	end
	local function group(pane,title)
		local grid,shell=UI.CreateAimSection(controls.Panes[pane],title,nil,#controls.Groups+1)
		local data={Grid=grid,Shell=shell,Items={}}
		controls.Groups[#controls.Groups+1]=data
		return data
	end
	local function changed()
		for _,record in pairs(State.Records) do record.ESPVisibilityAt=nil end
		ESP.RefreshAll()
		controls.Refresh()
		if State.UI.RefreshAimControls then State.UI.RefreshAimControls() end
	end
	local function add(section,key,title,description,kind,extra,dependency)
		local options={Id="ESP:"..key,Organizable=false,Description=description}
		local control
		if kind=="SLIDER" then
			control=UI.CreateSlider(section.Grid,title,extra[1],extra[2],Config[key],extra[3],function(value)
				Config[key]=value; changed()
			end,options)
		elseif kind=="CHOICE" then
			control=UI.CreateCycle(section.Grid,title,description,options)
			UI.BindChoiceMenu(control,title,extra,function() return Config[key] end,function(value)
				Config[key]=value; changed()
			end)
		else
			control=UI.CreateToggle(section.Grid,title,description,options)
			control.Card.Activated:Connect(function()
				if not Runtime.Alive or control.Available==false or State.UI.LayoutEditMode then return end
				Config[key]=not Config[key]; changed()
			end)
		end
		control.OriginalDescription=description
		local item={Key=key,Control=control,Kind=kind,Choices=extra,Dependency=dependency}
		controls.Items[#controls.Items+1]=item; section.Items[#section.Items+1]=item
		controls[key]=control
		UI.StyleESPControl(control)
		return control
	end
	local function normal() return ESP.UsesNormal(),"Escolha Normal ou Ambos em Tipo de ESP." end
	local function twoD() return ESP.Uses2D(),"Escolha 2D ou Ambos na seção Visual." end
	local function box() return ESP.Uses2D() and Config.ESP2DBox,"Ative a caixa no modo 2D." end
	local function info() return Config.ESPLabels,"Ative Mostrar informações." end
	local function health() return ESP.Uses2D() and Config.ESP2DHealth,"Ative a barra de vida no modo 2D." end
	local appearance=group("VISUAL","Aparência")
	add(appearance,"ESPRenderMode","Tipo de ESP","Escolha como os jogadores aparecem.","CHOICE",{
		{Value="NORMAL",Label="Normal",Description="Contorno no corpo do personagem."},
		{Value="2D",Label="2D",Description="Caixa na tela, com vida e informações."},
		{Value="BOTH",Label="Ambos",Description="Combina o contorno com o ESP 2D."},
	})
	add(appearance,"ESPThroughWalls","Através de paredes","Mostra o ESP mesmo com obstáculos na frente.")
	local contour=group("VISUAL","Contorno normal")
	add(contour,"ESPFillOpacity","Preenchimento","0% deixa só a borda. Aumente para colorir o corpo.","SLIDER",{0,100,"%"},normal)
	add(contour,"ESPOutlineOpacity","Intensidade da borda","Aumente para deixar o contorno mais visível.","SLIDER",{0,100,"%"},normal)
	local colors=group("VISUAL","Cores")
	add(colors,"ESPColorPreset","Cor do ESP","Define a cor dos contornos e das caixas.","CHOICE",{
		{Value="THEME",Label="Cor do menu"},{Value="RED",Label="Vermelho"},{Value="WHITE",Label="Branco"},
		{Value="CYAN",Label="Azul claro"},{Value="GREEN",Label="Verde"},{Value="PURPLE",Label="Roxo"},{Value="YELLOW",Label="Amarelo"},
	},function() return not Config.ESPUseTeamColors,"Desative Cores das equipes para escolher uma cor." end)
	add(colors,"ESPUseTeamColors","Cores das equipes","Usa a cor de cada equipe informada pelo jogo.")
	local labels=group("VISUAL","Informações")
	add(labels,"ESPLabels","Mostrar informações","Exibe os dados escolhidos acima do jogador.")
	add(labels,"ESPTextSize","Tamanho do texto","Aumente para ler melhor na tela do celular.","SLIDER",{9,20," px"},info)
	local details=group("VISUAL","Detalhes do texto")
	add(details,"ESPLabelNames","Nome do jogador","Mostra quem é o jogador.",nil,nil,info)
	add(details,"ESPLabelDistance","Distância","Mostra a distância da câmera até o jogador.",nil,nil,info)
	add(details,"ESPNameMode","Nome exibido","Apelido do jogo ou nome único da conta.","CHOICE",{
		{Value="DISPLAY",Label="Apelido"},{Value="USERNAME",Label="@usuário"},
	},function() return Config.ESPLabels and Config.ESPLabelNames,"Ative as informações e o nome do jogador." end)
	add(details,"ESPLabelTeam","Nome da equipe","Inclui a equipe no texto do jogador.",nil,nil,info)
	local boxes=group("2D","Caixa do jogador")
	add(boxes,"ESP2DBox","Mostrar caixa","Enquadra o corpo do jogador na tela.",nil,nil,twoD)
	add(boxes,"ESP2DStyle","Estilo da caixa","Borda inteira ou apenas os cantos.","CHOICE",{
		{Value="FULL",Label="Completa"},{Value="CORNERS",Label="Cantos"},
	},box)
	add(boxes,"ESP2DThickness","Espessura das linhas","Aumente para destacar a caixa e as linhas.","SLIDER",{1,4," px"},twoD)
	add(boxes,"ESP2DOutline","Borda escura","Melhora o contraste em cenários claros.",nil,nil,twoD)
	local fill=group("2D","Acabamento")
	add(fill,"ESP2DOpacity","Intensidade das linhas","Baixo fica discreto. Alto fica mais visível.","SLIDER",{10,100,"%"},twoD)
	add(fill,"ESP2DFillOpacity","Fundo da caixa","0% deixa transparente. Aumente para preencher.","SLIDER",{0,60,"%"},box)
	add(fill,"ESP2DPadding","Folga da caixa","Aumente para afastar a borda do corpo.","SLIDER",{0,12," px"},box)
	local life=group("2D","Vida")
	add(life,"ESP2DHealth","Barra de vida","Acompanha a vida. Some se o jogo não informar.",nil,nil,twoD)
	add(life,"ESP2DHealthText","Valor da vida","Mostra a quantidade de vida junto da barra.",nil,nil,health)
	add(life,"ESP2DHealthSide","Lado da barra","Escolha de que lado a vida aparece.","CHOICE",{
		{Value="LEFT",Label="Esquerda"},{Value="RIGHT",Label="Direita"},
	},health)
	local lines=group("2D","Linhas de localização")
	add(lines,"ESP2DTracers","Linha até o jogador","Liga um ponto da tela até a caixa do jogador.",nil,nil,twoD)
	add(lines,"ESP2DTracerOrigin","Início da linha","Escolha de onde a linha sai.","CHOICE",{
		{Value="BOTTOM",Label="Base da tela"},{Value="CENTER",Label="Centro da tela"},
	},function() return ESP.Uses2D() and Config.ESP2DTracers,"Ative Linha até o jogador no modo 2D." end)
	local filters=group("FILTERS","Quem aparece")
	add(filters,"GlobalESP","Mostrar todos","Inclui jogadores disponíveis e protegidos.")
	local function filtered() return not Config.GlobalESP,"Desative Mostrar todos para usar este filtro." end
	add(filters,"ESPEnemies","Jogadores disponíveis","Mostra quem você não marcou como protegido.",nil,nil,filtered)
	add(filters,"ESPAllies","Jogadores protegidos","Inclui quem foi marcado como protegido.",nil,nil,filtered)
	add(filters,"SelectedESP","Jogador escolhido","Inclui e destaca quem você marcou com FOCAR.")
	local range=group("FILTERS","Distância de exibição")
	add(range,"ESPMaxDistance","Distância máxima","0 = sem limite. Aumente para mostrar mais longe.","SLIDER",{0,20000," studs"})
	function controls.Layout()
		local columns=page.AbsoluteSize.X-14>=460 and 2 or 1
		for _,section in ipairs(controls.Groups) do
			local y=0
			for index=1,#section.Items,columns do
				local height=0
				for col=0,columns-1 do
					local item=section.Items[index+col]
					if item then height=math.max(height,UI.StyleESPControl(item.Control)) end
				end
				for col=0,columns-1 do
					local item=section.Items[index+col]
					if item then
						local wide=columns==1 or index==#section.Items
						item.Control.Card.Position=UDim2.new(wide and 0 or col/columns,col==0 and 0 or 5,0,y)
						item.Control.Card.Size=UDim2.new(wide and 1 or 1/columns,wide and 0 or -5,0,height)
					end
				end
				y+=height+10
			end
			section.Grid.Size=UDim2.new(1,0,0,math.max(0,y-10))
		end
	end
	function controls.Refresh()
		if not Runtime.Alive or not page.Parent then return end
		controls.Power.Text=Config.ESPEnabled and "ESP ativado" or "Ativar ESP"
		controls.Power.BackgroundColor3=Config.ESPEnabled and Theme.CardActive or Theme.Surface3
		for _,item in ipairs(controls.Items) do
			local control=item.Control
			if item.Kind=="SLIDER" then control:SetValue(Config[item.Key],false)
			elseif item.Kind=="CHOICE" then
				for _,choice in ipairs(item.Choices) do if choice.Value==Config[item.Key] then control.Value.Text=choice.Label; break end end
			else UI.SetToggle(control,Config[item.Key]) end
			local available,note=true,nil
			if item.Dependency then available,note=item.Dependency() end
			UI.SetControlAvailable(control,available,note)
		end
		controls.Layout()
	end
	function controls.Show(key)
		if not controls.Panes[key] or not Runtime.Alive then return end
		UI.CloseChoiceMenu()
		controls.Scroll[controls.Active]=page.CanvasPosition.Y
		local previous=controls.Active
		controls.Active=key; controls.Generation+=1
		local generation=controls.Generation
		for tab,pane in pairs(controls.Panes) do
			pane.Visible=tab==key
			Util.Tween(controls.Tabs[tab],{BackgroundTransparency=tab==key and .05 or 1,
				TextColor3=tab==key and Theme.Accent2 or Theme.Sub},.16)
		end
		controls.Refresh()
		if previous~=key and page.Visible then UI.RevealPage(page,1) end
		task.defer(function()
			S.RunService.Heartbeat:Wait()
			if Runtime.Alive and page.Parent and generation==controls.Generation then
				page.CanvasPosition=Vector2.new(0,controls.Scroll[key] or 0)
			end
		end)
	end
	controls.Power.Activated:Connect(function()
		if not Runtime.Alive or State.UI.LayoutEditMode then return end
		Config.ESPEnabled=not Config.ESPEnabled; changed()
	end)
	page:GetPropertyChangedSignal("AbsoluteSize"):Connect(controls.Layout)
	page:GetPropertyChangedSignal("Visible"):Connect(function() if page.Visible then controls.Refresh() end end)
	State.UI.ESPControls=controls
	State.UI.RefreshESPControls=controls.Refresh
	controls.Show("VISUAL")
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
	local narrow = width < 440
	entry.Card.Size = UDim2.new(1, 0, 0, narrow and 112 or 78)
	entry.Avatar.Position = UDim2.fromOffset(10, narrow and 10 or 19)
	local textRight = narrow and -76 or -252
	entry.Name.Size = UDim2.new(1, textRight, 0, 19)
	entry.Username.Size = UDim2.new(1, textRight, 0, 15)
	entry.Detail.Size = UDim2.new(1, textRight, 0, 15)
	if narrow then
		entry.Focus.Position = UDim2.fromOffset(12, 70)
		entry.Focus.Size = UDim2.new(0.5, -16, 0, 32)
		entry.Protect.Position = UDim2.new(0.5, 4, 0, 70)
		entry.Protect.Size = UDim2.new(0.5, -16, 0, 32)
	else
		entry.Focus.Position = UDim2.new(1, -184, 0, 22)
		entry.Focus.Size = UDim2.fromOffset(78, 32)
		entry.Protect.Position = UDim2.new(1, -98, 0, 22)
		entry.Protect.Size = UDim2.fromOffset(86, 32)
	end
end

function Pages.BuildPlayers()
	local page = UI.CreatePage("Players")
	page:SetAttribute("AAPHideScrollCue", true)
	page.Position = UDim2.fromOffset(3, 3)
	page.Size = UDim2.new(1, -6, 1, -6)
	page.ScrollBarThickness = 5
	local controls = {Entries = {}, Filter = "ALL", Query = "", SearchGeneration = 0}
	local toolbar = Util.New("Frame", {
		Name = "AAP_PlayerToolbar", LayoutOrder = -100,
		Size = UDim2.new(1, 0, 0, 78), BackgroundTransparency = 1,
		BorderSizePixel = 0, Visible = page.Visible,
	}, page)
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
		Size = UDim2.fromOffset(30, 32), BackgroundTransparency = 1, Text = "×",
		TextColor3 = Theme.Sub, Font = Enum.Font.Gotham, TextSize = 14,
		AutoButtonColor = false, Visible = false,
	}, searchCard)
	controls.TapSelect = Util.New("TextButton", {
		Name = "AAP_PlayerTapSelect", Position = UDim2.new(1, -136, 0, 0),
		Size = UDim2.fromOffset(120, 32), BackgroundColor3 = Theme.Card,
		BackgroundTransparency = 0.15, BorderSizePixel = 0, Text = "", AutoButtonColor = false,
	}, toolbar)
	Util.Corner(controls.TapSelect, 10)
	Util.Stroke(controls.TapSelect, Theme.BorderSoft, 0.65, 1)
	Util.FitText(Util.New("TextLabel", {
		Position = UDim2.fromOffset(7, 0), Size = UDim2.new(1, -42, 1, 0),
		BackgroundTransparency = 1, Text = "Toque no jogo", TextColor3 = Theme.Text,
		Font = Enum.Font.GothamMedium, TextSize = 8, TextXAlignment = Enum.TextXAlignment.Left,
	}, controls.TapSelect), 9, 9)
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
		Size = UDim2.new(1, 0, 0, 32), BackgroundColor3 = Theme.Surface2,
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
		Util.FitText(button, 9, 10)
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
		Padding = UDim.new(0, 10), SortOrder = Enum.SortOrder.LayoutOrder,
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
			Font = Enum.Font.GothamBold, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left,
		}, entry.Card)
		entry.Username = Util.New("TextLabel", {
			Position = UDim2.fromOffset(60, 30), BackgroundTransparency = 1,
			Text = "@" .. player.Name, TextColor3 = Theme.Sub, TextTruncate = Enum.TextTruncate.AtEnd,
			Font = Enum.Font.Gotham, TextSize = 9, TextXAlignment = Enum.TextXAlignment.Left,
		}, entry.Card)
		entry.Detail = Util.New("TextLabel", {
			Position = UDim2.fromOffset(60, 48), BackgroundTransparency = 1, Text = "",
			TextColor3 = Theme.Sub, TextTruncate = Enum.TextTruncate.AtEnd,
			Font = Enum.Font.GothamMedium, TextSize = 8, TextXAlignment = Enum.TextXAlignment.Left,
		}, entry.Card)
		for _, key in ipairs({"Focus", "Protect"}) do
			entry[key] = Util.New("TextButton", {
				BackgroundColor3 = Theme.Surface3, BackgroundTransparency = 0.05,
				BorderSizePixel = 0, Text = "", TextColor3 = Theme.Text,
				Font = Enum.Font.GothamMedium, TextSize = 8, AutoButtonColor = false,
			}, entry.Card)
			Util.Corner(entry[key], 9)
			Util.FitText(entry[key], 9, 10)
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
		local narrow = toolbar.AbsoluteSize.X < 340
		searchCard.Size = UDim2.new(1, narrow and 0 or -160, 0, 32)
		controls.TapSelect.Position = narrow and UDim2.fromOffset(0, 40) or UDim2.new(1, -152, 0, 0)
		controls.Help.Position = UDim2.new(1, 0, 0, narrow and 42 or 2)
		filters.Position = UDim2.fromOffset(0, narrow and 80 or 40)
		toolbar.Size = UDim2.new(1, 0, 0, narrow and 114 or 74)
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
	if State.UI.ActiveHelpDialog or State.UI.ActiveChoiceMenu or next(UI.Motion.ClosingDialogs) then return true end
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
	-- Pages are prepared by the real initialization stages before navigation.
	State.UI.RefreshFilters = function()
		UI.RefreshTeamSidebar()
	end
	State.UI.RefreshTeams = function()
		UI.RefreshTeamSidebar()
	end

	State.UI.Nav = {
		Aim = UI.CreateNavButton("MIRA"),
		Assistant = UI.CreateNavButton("ARMAS"),
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
	local normalFill = 0.88
	local maximizedFill = 0.97
	local manualSize = nil
	local maximizeGeneration = 0
	local maximizeTransitioning = false
	local menuScaleTween = nil
	local menuScaleGeneration = 0

	local function settleWindow(keepVisibilityMotion)
		if not keepVisibilityMotion then UI.FinishWindowMotion(State.UI.Main) end
		Util.StopTween(State.UI.Main, true)
		menuScaleTween = nil
		menuScaleGeneration += 1
		maximizeGeneration += 1
		maximizeTransitioning = false
	end

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
		if maximizeTransitioning then
			Util.StopTween(State.UI.Main, true)
			maximizeTransitioning = false
			maximizeGeneration += 1
		end

		if menuScaleTween then
			pcall(function()
				menuScaleTween:Cancel()
			end)
			menuScaleTween = nil
		end

		if instant then
			Util.StopTween(State.UI.Main)
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
		settleWindow()
		UI.FinishPageTransition()
		UI.ResetTouchFeedback()
		minimized = false
		maximized = false
		maximizeTransitioning = false
		maximizeGeneration += 1
		manualSize = nil
		expandedPosition = UDim2.fromScale(0.5, 0.52)
		State.UI.Main.Position = expandedPosition
		UI.SetWindowVisible(State.UI.Main, true, true)
		UI.SetWindowVisible(State.UI.CompactBar, false, true)
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
		settleWindow(true)
		UI.CloseHelpDialog(true)
		UI.CloseChoiceMenu(true)
		UI.FlushClosingDialogs()
		UI.FinishPageTransition()
		UI.ResetTouchFeedback()

		if not maximized then
			local motion = UI.Motion.Windows[State.UI.Main]
			expandedSize = State.UI.Main.Size
			expandedPosition = motion and motion.Rest or State.UI.Main.Position
		end

		minimized = true
		State.UI.CompactSub.Text = State.UI.Status.Text
		UI.SetWindowVisible(State.UI.Main, false)
		UI.SetWindowVisible(State.UI.CompactBar, true)
		task.defer(UI.ClampMovableToViewport)
	end)

	State.UI.CompactOpen.MouseButton1Click:Connect(function()
		if not minimized then
			return
		end
		minimized = false
		UI.SetWindowVisible(State.UI.CompactBar, false)
		setMaximizeConstraint()
		if not UI.Motion.Windows[State.UI.Main] then
			State.UI.Main.Size = maximized and GetVisionMenuSize(maximizedFill, 1) or expandedSize
			State.UI.Main.Position = maximized and UDim2.fromScale(0.5, 0.52) or expandedPosition
		end
		UI.SetWindowVisible(State.UI.Main, true)
		task.defer(UI.ClampMovableToViewport)
	end)

	if State.UI.Maximize then
		State.UI.Maximize.MouseButton1Click:Connect(function()
			if minimized then return end
			UI.FinishWindowMotion(State.UI.Main)
			local wasTransitioning = maximizeTransitioning
			if menuScaleTween then
				Util.StopTween(State.UI.Main, true)
				menuScaleTween = nil
				menuScaleGeneration += 1
			end

			maximizeTransitioning = true
			maximized = not maximized
			maximizeGeneration += 1
			local generation = maximizeGeneration
			if maximized then
				if not wasTransitioning then
					expandedSize = State.UI.Main.Size
					expandedPosition = State.UI.Main.Position
				end
				setMaximizeConstraint()
				Util.Tween(State.UI.Main, {
					Position = UDim2.fromScale(0.5, 0.52),
					Size = GetVisionMenuSize(maximizedFill, 1),
				}, 0.20)
				State.UI.Maximize.Text = "="
				if State.UI.ResizeHandle then
					State.UI.ResizeHandle.Visible = false
				end

				task.delay(0.22, function()
					if generation == maximizeGeneration then
						maximizeTransitioning = false
					end
				end)
			else
				Util.Tween(State.UI.Main, {
					Position = expandedPosition,
					Size = expandedSize,
				}, 0.20)
				State.UI.Maximize.Text = "+"
				if State.UI.ResizeHandle then
					State.UI.ResizeHandle.Visible = true
				end

				task.delay(0.22, function()
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
		if maximized or minimized then
			return
		end
		if input.UserInputType == Enum.UserInputType.Touch
			or input.UserInputType == Enum.UserInputType.MouseButton1 then
			if drag.MenuInput and drag.MenuInput ~= input then
				return
			end

			settleWindow()
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

			settleWindow()
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

			UI.FinishWindowMotion(State.UI.CompactBar)
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

		settleWindow()
		UI.FinishWindowMotion(State.UI.CompactBar)
		UI.FinishPageTransition()
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

	if not character or not character:IsA("Model") then

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
			or expectedCharacter ~= character then

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

	if character then
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

	ESP.Start()
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
	ESP.Stop()
	Loading.Destroy()
	if UI.ActiveNumericSlider then UI.ActiveNumericSlider:FinishEditing(false) end
	UI.CloseHelpDialog()
	UI.CloseChoiceMenu()
	UI.CleanupMotion()
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

local function WireVisionRuntimeEvents()
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
end

--==============================================================
-- INITIALIZATION — each check represents completed work, not a timer.
--==============================================================

local function InitializeVisionX()
	ClearPreviousVisionUI()
	Loading.Create()
	Loading.Stage(1, function()
		BuildVisionRootUI()
		Runtime.Track(State.UI.CleanupEvent.Event:Connect(Runtime.Cleanup))
		Runtime.Track(State.UI.Root.Destroying:Connect(Runtime.Cleanup))
		Runtime.Track(State.UI.Root.AncestryChanged:Connect(function(_, parent)
			if not parent then Runtime.Cleanup() end
		end))
	end)

	State.UI.Pages = {}
	Loading.Stage(2, function()
		State.UI.Pages.Aim = Pages.BuildVisionAim()
		Loading.Yield()
		State.UI.Pages.Assistant = Pages.BuildAssistant()
	end)
	Loading.Stage(3, function()
		State.UI.Pages.Body = Pages.BuildBody()
	end)
	Loading.Stage(4, function()
		State.UI.Pages.Players = Pages.BuildPlayers()
		-- Subscribe before the initial snapshot; players joining during a yield
		-- must not disappear from the directory or character cache.
		WireVisionRuntimeEvents()
		for index, player in ipairs(S.Players:GetPlayers()) do
			if player.Parent == S.Players then SetupPlayer(player) end
			if index % 8 == 0 then Loading.Yield() end
		end
	end)
	Loading.Stage(5, function()
		State.UI.Pages.ESP = Pages.BuildESP()
		ESP.RefreshAll()
	end)
	Loading.Stage(6, function()
		State.UI.Pages.Engine = Pages.BuildEngine()
		Loading.Yield()
		BuildNavigation()
		WireVisionGeneralUI()
		UI.WireWorldTapSelection()
		UI.RefreshQuick()
		UI.InitializeMotion()
		StartLoops()
		StartRender()
	end)
	Loading.Finish(function()
		if not Runtime.Alive or not State.UI.Root or not State.UI.Root.Parent then return end
		State.UI.Root.Enabled = true
		UI.SetWindowVisible(State.UI.Main, true)
		print("[VisionX V35.1.0 - ESP] carregado")
	end)
end

do
	local ok, problem = xpcall(InitializeVisionX, function(problem)
		if problem == Loading.Cancelled then return problem end
		return debug.traceback(tostring(problem), 2)
	end)
	if not ok then
		if problem == Loading.Cancelled or not Runtime.Alive then
			Loading.Destroy()
		else
			Loading.HandleError(problem)
		end
	end
end
