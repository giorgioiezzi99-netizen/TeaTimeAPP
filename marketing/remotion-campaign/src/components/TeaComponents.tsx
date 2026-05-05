import { CSSProperties, ReactNode } from "react";
import {
  AbsoluteFill,
  Img,
  interpolate,
  spring,
  staticFile,
  useCurrentFrame,
  useVideoConfig,
} from "remotion";

export const palette = {
  cream: "#F7EEDB",
  porcelain: "#FFF8EA",
  green: "#73DB87",
  deepGreen: "#163522",
  appBlack: "#070B08",
  panel: "rgba(0,0,0,0.34)",
  panelStrong: "rgba(0,0,0,0.52)",
  brown: "#4E2F22",
  gold: "#F2B44A",
  softGold: "#F4D892",
  mutedWhite: "rgba(255,255,255,0.66)",
  white: "#FFFFFF",
};

export type TeaKind = {
  id: string;
  shortName: string;
  name: string;
  category: string;
  temperature: string;
  steepTime: string;
  caffeine: string;
  flavor: string;
  detail: string;
  image: string;
  tint: string;
};

export const teas: TeaKind[] = [
  {
    id: "green",
    shortName: "Green",
    name: "Green Tea",
    category: "Fresh",
    temperature: "80 C",
    steepTime: "2:30",
    caffeine: "Medium",
    flavor: "Grassy, bright, lightly sweet",
    detail: "Cooler water keeps delicate green tea clean and fresh.",
    image: "green-tea-leaves.png",
    tint: "#73DB87",
  },
  {
    id: "black",
    shortName: "Black",
    name: "Black Tea",
    category: "Bold",
    temperature: "95 C",
    steepTime: "4:00",
    caffeine: "High",
    flavor: "Malty, rich, full-bodied",
    detail: "Hot water brings out deep structure and a stronger aroma.",
    image: "black-tea-leaves.png",
    tint: "#F2AB47",
  },
  {
    id: "oolong",
    shortName: "Oolong",
    name: "Oolong",
    category: "Layered",
    temperature: "90 C",
    steepTime: "3:30",
    caffeine: "Medium",
    flavor: "Floral, toasted, silky",
    detail: "Balanced heat helps unlock layered aroma and sweetness.",
    image: "oolong-tea-leaves.png",
    tint: "#B3D6AD",
  },
  {
    id: "white",
    shortName: "White",
    name: "White Tea",
    category: "Soft",
    temperature: "75 C",
    steepTime: "3:00",
    caffeine: "Low",
    flavor: "Honeyed, gentle, clean",
    detail: "Lower temperature keeps the cup delicate and naturally sweet.",
    image: "white-tea-leaves.png",
    tint: "#EBE0B3",
  },
  {
    id: "herbal",
    shortName: "Herbal",
    name: "Herbal",
    category: "Calm",
    temperature: "100 C",
    steepTime: "5:00",
    caffeine: "None",
    flavor: "Aromatic, soothing, expressive",
    detail: "Botanical infusions open fully with boiling water.",
    image: "herbal-tea-leaves.png",
    tint: "#D48CE0",
  },
];

const fill: CSSProperties = { width: "100%", height: "100%" };

const appAsset = (file: string) => staticFile(`/assets/app/${file}`);
const generatedAsset = (file: string) => staticFile(`/assets/generated/${file}`);

const backgroundForTea = (tea: TeaKind) => appAsset(tea.image);

export const GeneratedBackground: React.FC<{
  image: string;
  children: ReactNode;
  dark?: number;
  tint?: string;
}> = ({ image, children, dark = 0.34, tint = palette.green }) => {
  const frame = useCurrentFrame();
  const drift = interpolate(frame, [0, 900], [0, -34], {
    extrapolateRight: "extend",
  });

  return (
    <AbsoluteFill
      style={{
        overflow: "hidden",
        background: palette.appBlack,
        color: palette.white,
        fontFamily:
          'ui-sans-serif, system-ui, -apple-system, BlinkMacSystemFont, "SF Pro Display", "Helvetica Neue", sans-serif',
      }}
    >
      <Img
        src={generatedAsset(image)}
        style={{
          ...fill,
          objectFit: "cover",
          transform: `scale(1.04) translateY(${drift}px)`,
          filter: "saturate(0.96) contrast(1.02)",
        }}
      />
      <AbsoluteFill
        style={{
          background: `linear-gradient(180deg, rgba(0,0,0,${dark}) 0%, rgba(0,0,0,0.18) 42%, rgba(0,0,0,0.72) 100%)`,
        }}
      />
      <AbsoluteFill
        style={{
          background: `radial-gradient(circle at 72% 18%, ${tint}33, transparent 28%), radial-gradient(circle at 20% 92%, rgba(0,0,0,0.62), transparent 36%)`,
        }}
      />
      {children}
    </AbsoluteFill>
  );
};

export const AppLeafBackground: React.FC<{
  tea: TeaKind;
  children: ReactNode;
}> = ({ tea, children }) => {
  const frame = useCurrentFrame();
  const scale = interpolate(Math.sin(frame / 80), [-1, 1], [1.1, 1.14]);

  return (
    <AbsoluteFill
      style={{
        overflow: "hidden",
        background: palette.appBlack,
        color: palette.white,
        fontFamily:
          'ui-sans-serif, system-ui, -apple-system, BlinkMacSystemFont, "SF Pro Display", "Helvetica Neue", sans-serif',
      }}
    >
      <Img
        src={backgroundForTea(tea)}
        style={{
          ...fill,
          objectFit: "cover",
          transform: `scale(${scale})`,
          filter: "blur(3px) saturate(0.88) contrast(0.96)",
          opacity: 0.92,
        }}
      />
      <AbsoluteFill
        style={{
          background:
            "linear-gradient(180deg, rgba(0,0,0,0.48), rgba(0,0,0,0.38), rgba(0,0,0,0.78))",
        }}
      />
      <AbsoluteFill
        style={{
          background:
            "linear-gradient(90deg, rgba(5,8,6,0.72), rgba(0,0,0,0.14), rgba(5,5,6,0.82))",
        }}
      />
      <AbsoluteFill
        style={{
          background: `radial-gradient(circle at 68% 20%, ${tea.tint}38, transparent 24%), radial-gradient(circle at center, transparent 16%, rgba(0,0,0,0.64) 100%)`,
        }}
      />
      {children}
    </AbsoluteFill>
  );
};

export const SceneCopy: React.FC<{
  eyebrow?: string;
  title: string;
  body?: string;
  top?: number;
  align?: "left" | "center";
}> = ({ eyebrow, title, body, top = 145, align = "left" }) => {
  const frame = useCurrentFrame();
  const rise = spring({
    frame,
    fps: 30,
    config: { damping: 19, stiffness: 90, mass: 0.85 },
  });

  return (
    <div
      style={{
        position: "absolute",
        top,
        left: 66,
        right: 66,
        textAlign: align,
        opacity: interpolate(frame, [0, 16], [0, 1], {
          extrapolateRight: "clamp",
        }),
        transform: `translateY(${interpolate(rise, [0, 1], [36, 0])}px)`,
        textShadow: "0 16px 42px rgba(0,0,0,0.36)",
      }}
    >
      {eyebrow ? (
        <div
          style={{
            marginBottom: 18,
            color: palette.softGold,
            fontSize: 25,
            fontWeight: 760,
            textTransform: "uppercase",
          }}
        >
          {eyebrow}
        </div>
      ) : null}
      <div
        style={{
          fontSize: title.length > 34 ? 66 : 78,
          lineHeight: 1.02,
          fontWeight: 820,
          letterSpacing: 0,
        }}
      >
        {title}
      </div>
      {body ? (
        <div
          style={{
            marginTop: 24,
            color: "rgba(255,255,255,0.76)",
            fontSize: 33,
            lineHeight: 1.28,
            fontWeight: 540,
          }}
        >
          {body}
        </div>
      ) : null}
    </div>
  );
};

export const PhoneMockup: React.FC<{
  children: ReactNode;
  scale?: number;
  y?: number;
  x?: number;
  rotate?: number;
}> = ({ children, scale = 1, y = 0, x = 0, rotate = 0 }) => {
  const frame = useCurrentFrame();
  const float = Math.sin(frame / 42) * 7;
  const entrance = spring({
    frame: frame - 5,
    fps: 30,
    config: { damping: 18, stiffness: 74 },
  });

  return (
    <div
      style={{
        position: "absolute",
        left: "50%",
        top: 585 + y,
        width: 560,
        height: 1148,
        transform: `translateX(-50%) translateX(${x}px) translateY(${interpolate(
          entrance,
          [0, 1],
          [116, float],
        )}px) scale(${scale}) rotate(${rotate}deg)`,
        transformOrigin: "center",
        borderRadius: 82,
        background: "linear-gradient(145deg, #151814, #010201)",
        boxShadow:
          "0 54px 110px rgba(0,0,0,0.42), 0 18px 58px rgba(242,180,74,0.16), inset 0 0 0 5px rgba(255,255,255,0.10)",
        padding: 18,
      }}
    >
      <div
        style={{
          ...fill,
          overflow: "hidden",
          position: "relative",
          borderRadius: 64,
          background: palette.appBlack,
          boxShadow: "inset 0 0 0 1px rgba(255,255,255,0.08)",
        }}
      >
        <div
          style={{
            position: "absolute",
            top: 16,
            left: "50%",
            transform: "translateX(-50%)",
            width: 164,
            height: 36,
            borderRadius: 999,
            background: "#020403",
            zIndex: 20,
          }}
        />
        {children}
      </div>
    </div>
  );
};

const CircleIcon: React.FC<{
  children: ReactNode;
  tint: string;
  size?: number;
}> = ({ children, tint, size = 76 }) => (
  <div
    style={{
      width: size,
      height: size,
      borderRadius: "50%",
      display: "flex",
      alignItems: "center",
      justifyContent: "center",
      background:
        "linear-gradient(135deg, rgba(255,255,255,0.12), rgba(0,0,0,0.28))",
      border: "1px solid rgba(255,255,255,0.15)",
      boxShadow: `0 12px 26px rgba(0,0,0,0.35), inset 0 0 0 5px ${tint}22`,
      color: tint,
      fontWeight: 820,
      fontSize: size * 0.36,
    }}
  >
    {children}
  </div>
);

const Header: React.FC<{ tea: TeaKind }> = ({ tea }) => (
  <div
    style={{
      display: "flex",
      alignItems: "flex-start",
      justifyContent: "space-between",
      padding: "70px 34px 0",
      position: "relative",
      zIndex: 2,
    }}
  >
    <div>
      <div
        style={{
          fontFamily: "Georgia, 'Times New Roman', serif",
          fontSize: 51,
          fontWeight: 760,
          lineHeight: 1,
          textShadow: "0 8px 22px rgba(0,0,0,0.52)",
        }}
      >
        Tea Timer
      </div>
      <div
        style={{
          marginTop: 10,
          color: "rgba(255,255,255,0.70)",
          fontSize: 19,
          fontWeight: 560,
        }}
      >
        Precise steeping for a cleaner, richer cup.
      </div>
    </div>
    <CircleIcon tint={tea.tint} size={48}>
      <span style={{ fontSize: 21 }}>▭</span>
    </CircleIcon>
  </div>
);

export const TeaPortrait: React.FC<{
  tea: TeaKind;
  selected?: boolean;
  delay?: number;
}> = ({ tea, selected = false, delay = 0 }) => {
  const frame = useCurrentFrame();
  const local = Math.max(0, frame - delay);
  const pop = spring({
    frame: local,
    fps: 30,
    config: { damping: 17, stiffness: 120 },
  });

  return (
    <div
      style={{
        width: 86,
        height: 120,
        opacity: interpolate(local, [0, 12], [0, 1], {
          extrapolateRight: "clamp",
        }),
        transform: `translateY(${interpolate(pop, [0, 1], [20, 0])}px)`,
        display: "flex",
        flexDirection: "column",
        alignItems: "center",
        gap: 11,
      }}
    >
      <div
        style={{
          width: 76,
          height: 76,
          borderRadius: "50%",
          position: "relative",
          overflow: "hidden",
          boxShadow: selected
            ? `0 0 0 4px ${tea.tint}, 0 12px 28px ${tea.tint}66`
            : "0 10px 20px rgba(0,0,0,0.42)",
        }}
      >
        <Img
          src={appAsset(tea.image)}
          style={{
            width: "100%",
            height: "100%",
            objectFit: "cover",
          }}
        />
        <div
          style={{
            position: "absolute",
            inset: 0,
            background:
              "linear-gradient(180deg, transparent, rgba(0,0,0,0.25))",
          }}
        />
      </div>
      <div
        style={{
          color: selected ? tea.tint : "rgba(255,255,255,0.64)",
          fontSize: 15,
          fontWeight: 720,
          textAlign: "center",
          whiteSpace: "nowrap",
        }}
      >
        {tea.shortName}
      </div>
    </div>
  );
};

const ScanPortrait: React.FC<{ tint: string; delay?: number }> = ({
  tint,
  delay = 0,
}) => {
  const frame = useCurrentFrame();
  const local = Math.max(0, frame - delay);
  return (
    <div
      style={{
        width: 86,
        height: 120,
        opacity: interpolate(local, [0, 12], [0, 1], {
          extrapolateRight: "clamp",
        }),
        display: "flex",
        flexDirection: "column",
        alignItems: "center",
        gap: 11,
      }}
    >
      <CircleIcon tint={tint}>⌗</CircleIcon>
      <div
        style={{
          color: "rgba(255,255,255,0.72)",
          fontSize: 15,
          fontWeight: 720,
          whiteSpace: "nowrap",
        }}
      >
        Scan Tea
      </div>
    </div>
  );
};

const Stat: React.FC<{
  title: string;
  value: string;
  tint: string;
}> = ({ title, value, tint }) => (
  <div
    style={{
      flex: 1,
      minWidth: 0,
      padding: "14px 10px",
      borderRadius: 8,
      background: "rgba(0,0,0,0.30)",
      border: "1px solid rgba(255,255,255,0.09)",
      textAlign: "center",
    }}
  >
    <div style={{ color: "rgba(255,255,255,0.42)", fontSize: 12 }}>
      {title}
    </div>
    <div
      style={{
        marginTop: 5,
        color: tint,
        fontSize: 17,
        fontWeight: 780,
      }}
    >
      {value}
    </div>
  </div>
);

export const TeaSelectionScreen: React.FC<{
  selectedId?: string;
  showScanner?: boolean;
}> = ({ selectedId = "green", showScanner = true }) => {
  const selected = teas.find((tea) => tea.id === selectedId) ?? teas[0];

  return (
    <AppLeafBackground tea={selected}>
      <Header tea={selected} />
      <div
        style={{
          position: "relative",
          zIndex: 2,
          padding: "30px 28px 0",
          display: "flex",
          gap: 16,
          alignItems: "flex-start",
          overflow: "hidden",
        }}
      >
        {teas.map((tea, index) => (
          <TeaPortrait
            key={tea.id}
            tea={tea}
            selected={tea.id === selected.id}
            delay={index * 4}
          />
        ))}
        {showScanner ? <ScanPortrait tint={selected.tint} delay={24} /> : null}
      </div>
      <TimerPanel tea={selected} compact={false} />
    </AppLeafBackground>
  );
};

export const TeaPickerShowcaseScreen: React.FC<{ selectedId?: string }> = ({
  selectedId = "green",
}) => {
  const selected = teas.find((tea) => tea.id === selectedId) ?? teas[0];

  return (
    <AppLeafBackground tea={selected}>
      <Header tea={selected} />
      <div
        style={{
          position: "relative",
          zIndex: 2,
          padding: "42px 30px 0",
        }}
      >
        <div
          style={{
            color: selected.tint,
            fontSize: 15,
            fontWeight: 820,
            textTransform: "uppercase",
          }}
        >
          Choose Tea
        </div>
        <div
          style={{
            marginTop: 12,
            color: palette.white,
            fontSize: 34,
            lineHeight: 1.06,
            fontWeight: 820,
          }}
        >
          Pick the leaves in your cup.
        </div>
        <div
          style={{
            marginTop: 24,
            display: "flex",
            justifyContent: "space-between",
            gap: 8,
          }}
        >
          {teas.map((tea) => (
            <div
              key={tea.id}
              style={{
                width: 74,
                display: "flex",
                flexDirection: "column",
                alignItems: "center",
                gap: 8,
              }}
            >
              <div
                style={{
                  width: 62,
                  height: 62,
                  borderRadius: "50%",
                  overflow: "hidden",
                  boxShadow:
                    tea.id === selected.id
                      ? `0 0 0 4px ${tea.tint}, 0 14px 28px ${tea.tint}44`
                      : "0 10px 22px rgba(0,0,0,0.36)",
                }}
              >
                <Img
                  src={appAsset(tea.image)}
                  style={{ width: "100%", height: "100%", objectFit: "cover" }}
                />
              </div>
              <div
                style={{
                  color: tea.id === selected.id ? tea.tint : palette.mutedWhite,
                  fontSize: 13,
                  fontWeight: 780,
                  whiteSpace: "nowrap",
                }}
              >
                {tea.shortName}
              </div>
            </div>
          ))}
        </div>
        <div
          style={{
            marginTop: 24,
            padding: 16,
            borderRadius: 8,
            background: "rgba(0,0,0,0.38)",
            border: `1px solid ${selected.tint}88`,
            boxShadow: "0 16px 44px rgba(0,0,0,0.28)",
          }}
        >
          <div
            style={{
              display: "flex",
              alignItems: "center",
              justifyContent: "space-between",
              gap: 12,
            }}
          >
            <div>
              <div style={{ color: selected.tint, fontSize: 15, fontWeight: 820 }}>
                Selected
              </div>
              <div
                style={{
                  marginTop: 7,
                  color: palette.white,
                  fontSize: 32,
                  fontWeight: 830,
                }}
              >
                {selected.name}
              </div>
            </div>
            <div
              style={{
                color: selected.tint,
                fontSize: 30,
                fontWeight: 830,
              }}
            >
              {selected.steepTime}
            </div>
          </div>
          <div style={{ marginTop: 16, display: "flex", gap: 8 }}>
            <Stat title="Water" value={selected.temperature} tint={selected.tint} />
            <Stat title="Infusion" value={selected.steepTime} tint={selected.tint} />
            <Stat title="Caffeine" value={selected.caffeine} tint={selected.tint} />
          </div>
          <div
            style={{
              marginTop: 14,
              color: "rgba(255,255,255,0.64)",
              fontSize: 15,
              lineHeight: 1.32,
              fontWeight: 560,
            }}
          >
            {selected.flavor}
          </div>
        </div>
        <div
          style={{
            marginTop: 14,
            padding: 14,
            borderRadius: 8,
            background: "rgba(0,0,0,0.34)",
            border: "1px solid rgba(255,255,255,0.10)",
            display: "flex",
            alignItems: "center",
            gap: 14,
          }}
        >
          <CircleIcon tint={selected.tint} size={48}>
            ⌗
          </CircleIcon>
          <div>
            <div style={{ color: palette.white, fontSize: 19, fontWeight: 820 }}>
              Scan Tea
            </div>
            <div
              style={{
                marginTop: 4,
                color: "rgba(255,255,255,0.58)",
                fontSize: 14,
              }}
            >
              Scan package text and suggest infusion settings.
            </div>
          </div>
        </div>
      </div>
    </AppLeafBackground>
  );
};

export const TimerPanel: React.FC<{
  tea: TeaKind;
  secondsText?: string;
  running?: boolean;
  compact?: boolean;
}> = ({ tea, secondsText, running = false, compact = true }) => {
  const frame = useCurrentFrame();
  const progress = interpolate(frame, [0, 150], [0.98, running ? 0.42 : 0.68], {
    extrapolateRight: "clamp",
  });
  const radius = compact ? 156 : 166;
  const size = compact ? 386 : 410;
  const circumference = Math.PI * radius * 2;

  return (
    <div
      style={{
        position: "relative",
        zIndex: 2,
        marginTop: compact ? 46 : 28,
        padding: "0 30px",
        display: "flex",
        flexDirection: "column",
        alignItems: "center",
      }}
    >
      <div
        style={{
          width: size,
          height: size,
          borderRadius: "50%",
          position: "relative",
          display: "flex",
          alignItems: "center",
          justifyContent: "center",
          background:
            "radial-gradient(circle, rgba(0,0,0,0.46), rgba(0,0,0,0.22), rgba(0,0,0,0.14))",
          boxShadow: "0 24px 56px rgba(0,0,0,0.44)",
          border: "1px solid rgba(255,255,255,0.06)",
        }}
      >
        <svg width={size} height={size} viewBox={`0 0 ${size} ${size}`}>
          <circle
            cx={size / 2}
            cy={size / 2}
            r={radius}
            fill="none"
            stroke={`${tea.tint}40`}
            strokeWidth="14"
          />
          <circle
            cx={size / 2}
            cy={size / 2}
            r={radius}
            fill="none"
            stroke={tea.tint}
            strokeLinecap="round"
            strokeWidth="14"
            strokeDasharray={circumference}
            strokeDashoffset={circumference * (1 - progress)}
            transform={`rotate(-90 ${size / 2} ${size / 2})`}
          />
          <circle
            cx={size / 2}
            cy={size / 2}
            r={radius}
            fill="none"
            stroke={palette.gold}
            strokeLinecap="round"
            strokeWidth="4"
            strokeDasharray="48 940"
            transform={`rotate(${frame * 0.35 - 90} ${size / 2} ${
              size / 2
            })`}
            opacity="0.9"
          />
        </svg>
        <div
          style={{
            position: "absolute",
            inset: 0,
            display: "flex",
            flexDirection: "column",
            alignItems: "center",
            justifyContent: "center",
            gap: 10,
          }}
        >
          <div style={{ color: tea.tint, fontSize: 27 }}>●</div>
          <div style={{ color: tea.tint, fontSize: 25, fontWeight: 760 }}>
            {tea.name}
          </div>
          <div
            style={{
              fontFamily: "Georgia, 'Times New Roman', serif",
              color: palette.white,
              fontSize: compact ? 74 : 78,
              fontWeight: 400,
              lineHeight: 1,
            }}
          >
            {secondsText ?? tea.steepTime}
          </div>
          <div style={{ color: "rgba(255,255,255,0.48)", fontSize: 16 }}>
            min
          </div>
          <div style={{ color: tea.tint, fontSize: 19, fontWeight: 740 }}>
            {tea.temperature}
          </div>
        </div>
      </div>
      <div
        style={{
          marginTop: 20,
          padding: "10px 17px",
          borderRadius: 999,
          background: "rgba(0,0,0,0.27)",
          border: "1px solid rgba(255,255,255,0.10)",
          display: "flex",
          gap: 16,
          color: "rgba(255,255,255,0.55)",
          fontSize: 13,
          fontWeight: 680,
        }}
      >
        <span>-</span>
        <span>Custom Timer</span>
        <span style={{ color: tea.tint }}>15 sec steps</span>
        <span>+</span>
      </div>
      <div
        style={{
          marginTop: 18,
          width: "100%",
          display: "flex",
          gap: 12,
        }}
      >
        <div
          style={{
            flex: 1,
            height: 62,
            borderRadius: 999,
            background: tea.tint,
            color: "rgba(0,0,0,0.84)",
            display: "flex",
            alignItems: "center",
            justifyContent: "center",
            fontSize: 19,
            fontWeight: 820,
          }}
        >
          {running ? "Pause" : "Start"}
        </div>
        <div
          style={{
            width: 62,
            height: 62,
            borderRadius: "50%",
            display: "flex",
            alignItems: "center",
            justifyContent: "center",
            background: "rgba(255,255,255,0.09)",
            border: "1px solid rgba(255,255,255,0.12)",
            color: palette.white,
            fontSize: 22,
          }}
        >
          ↻
        </div>
      </div>
    </div>
  );
};

export const FlavorPanel: React.FC<{ tea: TeaKind }> = ({ tea }) => (
  <div
    style={{
      position: "absolute",
      left: 30,
      right: 30,
      bottom: 34,
      zIndex: 2,
    }}
  >
    <div
      style={{
        display: "flex",
        gap: 10,
        marginBottom: 14,
      }}
    >
      <Stat title="Water" value={tea.temperature} tint={tea.tint} />
      <Stat title="Infusion" value={tea.steepTime} tint={tea.tint} />
      <Stat title="Caffeine" value={tea.caffeine} tint={tea.tint} />
    </div>
    <div
      style={{
        padding: 22,
        borderRadius: 8,
        background:
          "linear-gradient(145deg, rgba(0,0,0,0.38), rgba(0,0,0,0.26))",
        border: `1px solid ${tea.tint}66`,
        boxShadow: "0 18px 48px rgba(0,0,0,0.30)",
      }}
    >
      <div style={{ color: tea.tint, fontSize: 18, fontWeight: 760 }}>
        Flavor Notes
      </div>
      <div
        style={{
          marginTop: 12,
          color: palette.white,
          fontSize: 24,
          fontWeight: 800,
          lineHeight: 1.15,
        }}
      >
        {tea.flavor}
      </div>
      <div
        style={{
          marginTop: 12,
          color: "rgba(255,255,255,0.64)",
          fontSize: 16,
          lineHeight: 1.35,
          fontWeight: 520,
        }}
      >
        {tea.detail}
      </div>
    </div>
  </div>
);

export const TimerScreen: React.FC<{ tea?: TeaKind }> = ({
  tea = teas[0],
}) => (
  <AppLeafBackground tea={tea}>
    <Header tea={tea} />
    <TimerPanel tea={tea} secondsText="02:16" running />
    <div
      style={{
        position: "absolute",
        left: 32,
        right: 32,
        bottom: 42,
        zIndex: 2,
        padding: 16,
        borderRadius: 8,
        background: "rgba(0,0,0,0.30)",
        border: "1px solid rgba(255,255,255,0.10)",
        display: "flex",
        alignItems: "center",
        gap: 14,
      }}
    >
      <CircleIcon tint={tea.tint} size={46}>
        ✦
      </CircleIcon>
      <div>
        <div style={{ fontSize: 17, fontWeight: 820 }}>
          Take a moment for yourself.
        </div>
        <div
          style={{
            marginTop: 4,
            color: "rgba(255,255,255,0.58)",
            fontSize: 14,
          }}
        >
          Add a thought while your tea is brewing.
        </div>
      </div>
    </div>
  </AppLeafBackground>
);

export const ScannerScreen: React.FC = () => {
  const frame = useCurrentFrame();
  const tea = teas[2];
  const scanY = interpolate(frame % 88, [0, 87], [290, 655]);

  return (
    <GeneratedBackground image="scanner-package-bg.png" tint={tea.tint} dark={0.2}>
      <div
        style={{
          position: "absolute",
          inset: 0,
          background: "linear-gradient(180deg, rgba(0,0,0,0.14), rgba(0,0,0,0.52))",
        }}
      />
      <div
        style={{
          position: "relative",
          zIndex: 2,
          padding: "82px 36px 0",
          textAlign: "center",
        }}
      >
        <CircleIcon tint={tea.tint} size={104}>
          ⌗
        </CircleIcon>
        <div
          style={{
            marginTop: 18,
            fontFamily: "Georgia, 'Times New Roman', serif",
            fontSize: 43,
            fontWeight: 760,
          }}
        >
          Scan Tea
        </div>
        <div
          style={{
            margin: "12px auto 0",
            width: 420,
            color: "rgba(255,255,255,0.70)",
            fontSize: 20,
            lineHeight: 1.25,
            fontWeight: 560,
          }}
        >
          Scan tea package text to detect tea type and suggest infusion settings.
        </div>
      </div>
      <div
        style={{
          position: "absolute",
          left: 42,
          right: 42,
          top: 360,
          height: 440,
          borderRadius: 8,
          border: "1px solid rgba(255,255,255,0.22)",
          background: "rgba(0,0,0,0.26)",
          boxShadow: "0 26px 70px rgba(0,0,0,0.32)",
          overflow: "hidden",
          zIndex: 3,
        }}
      >
        <div
          style={{
            position: "absolute",
            left: 24,
            right: 24,
            top: scanY - 360,
            height: 4,
            borderRadius: 999,
            background: palette.gold,
            boxShadow: "0 0 28px rgba(242,180,74,0.92)",
          }}
        />
        <div
          style={{
            position: "absolute",
            left: 28,
            right: 28,
            bottom: 26,
            padding: 18,
            borderRadius: 8,
            background: "rgba(0,0,0,0.48)",
            border: `1px solid ${tea.tint}66`,
          }}
        >
          <div style={{ color: tea.tint, fontSize: 16, fontWeight: 760 }}>
            Smart tea detection
          </div>
          <div style={{ marginTop: 8, fontSize: 25, fontWeight: 820 }}>
            Oolong Tea
          </div>
          <div
            style={{
              marginTop: 8,
              color: "rgba(255,255,255,0.64)",
              fontSize: 15,
            }}
          >
            Suggested infusion: 3:30 at 90 C
          </div>
        </div>
      </div>
      <div
        style={{
          position: "absolute",
          left: 42,
          right: 42,
          bottom: 50,
          zIndex: 3,
          display: "grid",
          gap: 12,
        }}
      >
        {[
          ["Demo Green", "Sencha Classic", "2:30"],
          ["Demo Black", "English Breakfast", "4:00"],
          ["Create Personalized Tea", "Save a custom timer", "+"],
        ].map(([label, title, time]) => (
          <div
            key={label}
            style={{
              padding: 15,
              borderRadius: 8,
              background: "rgba(0,0,0,0.34)",
              border: "1px solid rgba(255,255,255,0.10)",
              display: "flex",
              alignItems: "center",
              justifyContent: "space-between",
            }}
          >
            <div>
              <div
                style={{
                  color: "rgba(255,255,255,0.48)",
                  fontSize: 12,
                  fontWeight: 760,
                  textTransform: "uppercase",
                }}
              >
                {label}
              </div>
              <div style={{ marginTop: 5, fontSize: 18, fontWeight: 790 }}>
                {title}
              </div>
            </div>
            <div style={{ color: tea.tint, fontSize: 18, fontWeight: 820 }}>
              {time}
            </div>
          </div>
        ))}
      </div>
    </GeneratedBackground>
  );
};

export const ReviewScreen: React.FC = () => {
  const tea = teas[0];
  const moments = [
    ["Green Tea", "Peaceful", "2:30", "Today"],
    ["Oolong", "Focused", "3:30", "Yesterday"],
    ["Herbal", "Cozy", "5:00", "Mon"],
  ];

  return (
    <AppLeafBackground tea={tea}>
      <div
        style={{
          position: "relative",
          zIndex: 2,
          padding: "86px 34px 0",
        }}
      >
        <div
          style={{
            fontFamily: "Georgia, 'Times New Roman', serif",
            fontSize: 42,
            fontWeight: 760,
          }}
        >
          Tea Moments
        </div>
        <div
          style={{
            marginTop: 10,
            color: "rgba(255,255,255,0.64)",
            fontSize: 18,
            fontWeight: 560,
          }}
        >
          Review the cups you want to remember.
        </div>
        <div
          style={{
            marginTop: 26,
            display: "flex",
            gap: 8,
            padding: 5,
            borderRadius: 999,
            background: "rgba(255,255,255,0.08)",
            width: "100%",
          }}
        >
          {["Moments", "Stats", "Reviews"].map((tab, index) => (
            <div
              key={tab}
              style={{
                flex: 1,
                padding: "10px 0",
                borderRadius: 999,
                textAlign: "center",
                background: index === 0 ? tea.tint : "transparent",
                color: index === 0 ? "rgba(0,0,0,0.82)" : palette.mutedWhite,
                fontSize: 15,
                fontWeight: 800,
              }}
            >
              {tab}
            </div>
          ))}
        </div>
        <div style={{ marginTop: 28, display: "grid", gap: 14 }}>
          {moments.map(([name, mood, time, date], index) => {
            const itemTea = teas[index === 1 ? 2 : index === 2 ? 4 : 0];
            return (
              <div
                key={name}
                style={{
                  padding: 17,
                  borderRadius: 8,
                  display: "flex",
                  gap: 14,
                  alignItems: "center",
                  background: "rgba(0,0,0,0.34)",
                  border: "1px solid rgba(255,255,255,0.10)",
                  boxShadow: "0 14px 32px rgba(0,0,0,0.22)",
                }}
              >
                <TeaPortrait tea={itemTea} selected={index === 0} />
                <div style={{ flex: 1 }}>
                  <div
                    style={{
                      display: "flex",
                      justifyContent: "space-between",
                      color: "rgba(255,255,255,0.48)",
                      fontSize: 13,
                      fontWeight: 700,
                    }}
                  >
                    <span>{mood}</span>
                    <span>{date}</span>
                  </div>
                  <div
                    style={{
                      marginTop: 8,
                      fontSize: 24,
                      fontWeight: 830,
                      color: palette.white,
                    }}
                  >
                    {name}
                  </div>
                  <div
                    style={{
                      marginTop: 7,
                      color: itemTea.tint,
                      fontSize: 16,
                      fontWeight: 740,
                    }}
                  >
                    {time} infusion · {itemTea.temperature}
                  </div>
                </div>
              </div>
            );
          })}
        </div>
        <div
          style={{
            marginTop: 22,
            padding: 20,
            borderRadius: 8,
            background: "rgba(255,255,255,0.07)",
            border: `1px solid ${tea.tint}55`,
          }}
        >
          <div style={{ color: tea.tint, fontSize: 17, fontWeight: 800 }}>
            Green Tea Review
          </div>
          <div
            style={{
              marginTop: 10,
              color: palette.white,
              fontSize: 26,
              letterSpacing: 2,
            }}
          >
            ★★★★★
          </div>
          <div
            style={{
              marginTop: 10,
              color: "rgba(255,255,255,0.64)",
              fontSize: 16,
              lineHeight: 1.32,
            }}
          >
            Clean, bright, and exactly right for a focused morning.
          </div>
        </div>
      </div>
    </AppLeafBackground>
  );
};

export const CTAEndCard: React.FC<{ thumbnail?: boolean }> = ({
  thumbnail = false,
}) => {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();
  const scale = spring({
    frame,
    fps,
    config: { damping: 18, stiffness: 80 },
  });

  return (
    <GeneratedBackground image="hero-thumbnail-bg.png" tint={palette.green} dark={0.1}>
      <div
        style={{
          position: "absolute",
          inset: 0,
          background:
            "linear-gradient(180deg, rgba(0,0,0,0.16), rgba(0,0,0,0.04) 44%, rgba(0,0,0,0.76))",
        }}
      />
      <div
        style={{
          position: "absolute",
          left: 78,
          right: 78,
          top: thumbnail ? 168 : 186,
          textAlign: "center",
          textShadow: "0 18px 46px rgba(0,0,0,0.42)",
        }}
      >
        <Img
          src={appAsset("teatimer-app-icon.png")}
          style={{
            width: thumbnail ? 188 : 156,
            height: thumbnail ? 188 : 156,
            borderRadius: thumbnail ? 42 : 34,
            boxShadow: "0 28px 70px rgba(0,0,0,0.35)",
            transform: `scale(${interpolate(scale, [0, 1], [0.82, 1])})`,
          }}
        />
        <div
          style={{
            marginTop: thumbnail ? 46 : 38,
            fontFamily: "Georgia, 'Times New Roman', serif",
            fontSize: thumbnail ? 96 : 86,
            fontWeight: 780,
            lineHeight: 0.95,
          }}
        >
          TeaTimer
        </div>
        <div
          style={{
            marginTop: 24,
            fontSize: thumbnail ? 50 : 43,
            lineHeight: 1.1,
            fontWeight: 780,
            color: palette.softGold,
          }}
        >
          Perfect tea, every time.
        </div>
        {!thumbnail ? (
          <div
            style={{
              marginTop: 31,
              color: "rgba(255,255,255,0.72)",
              fontSize: 27,
              fontWeight: 620,
            }}
          >
            Now testing on iPhone
          </div>
        ) : null}
      </div>
    </GeneratedBackground>
  );
};

export const LifestyleProductScene: React.FC<{
  image: string;
  tea?: TeaKind;
  children?: ReactNode;
}> = ({ image, tea = teas[0], children }) => (
  <GeneratedBackground image={image} tint={tea.tint} dark={0.2}>
    {children}
  </GeneratedBackground>
);
