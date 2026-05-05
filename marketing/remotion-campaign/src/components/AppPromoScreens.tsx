import { ReactNode } from "react";
import {
  AbsoluteFill,
  Img,
  interpolate,
  spring,
  staticFile,
  useCurrentFrame,
} from "remotion";
import { palette, teas } from "./TeaComponents";

const generatedAsset = (file: string) => staticFile(`/assets/generated/${file}`);
const appAsset = (file: string) => staticFile(`/assets/app/${file}`);

type ScreenName =
  | "home"
  | "scanner"
  | "scanResult"
  | "editScan"
  | "savedTeas"
  | "timer"
  | "review";

const cardStyle = {
  borderRadius: 18,
  background: "rgba(0,0,0,0.40)",
  border: "1px solid rgba(255,255,255,0.10)",
} as const;

export const PromoBackdrop: React.FC<{
  image?: string;
  children: ReactNode;
  tint?: string;
}> = ({ image = "warm-tea-table-bg.png", children, tint = palette.green }) => {
  const frame = useCurrentFrame();
  const drift = interpolate(frame, [0, 900], [0, -42], {
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
          width: "100%",
          height: "100%",
          objectFit: "cover",
          transform: `scale(1.06) translateY(${drift}px)`,
          filter: "saturate(0.92) contrast(1.04)",
        }}
      />
      <AbsoluteFill
        style={{
          background:
            "linear-gradient(180deg, rgba(0,0,0,0.48), rgba(0,0,0,0.14) 42%, rgba(0,0,0,0.76))",
        }}
      />
      <AbsoluteFill
        style={{
          background: `radial-gradient(circle at 68% 18%, ${tint}38, transparent 26%), radial-gradient(circle at 20% 84%, rgba(0,0,0,0.68), transparent 32%)`,
        }}
      />
      {children}
    </AbsoluteFill>
  );
};

export const PromoCaption: React.FC<{
  eyebrow?: string;
  title: string;
  body?: string;
  top?: number;
  left?: number;
  right?: number;
  align?: "left" | "center";
}> = ({ eyebrow, title, body, top = 120, left = 64, right = 64, align = "left" }) => {
  const frame = useCurrentFrame();
  const reveal = spring({
    frame,
    fps: 30,
    config: { damping: 18, stiffness: 90 },
  });

  return (
    <div
      style={{
        position: "absolute",
        top,
        left,
        right,
        textAlign: align,
        opacity: interpolate(frame, [0, 14], [0, 1], {
          extrapolateRight: "clamp",
        }),
        transform: `translateY(${interpolate(reveal, [0, 1], [28, 0])}px)`,
        textShadow: "0 18px 48px rgba(0,0,0,0.45)",
      }}
    >
      {eyebrow ? (
        <div
          style={{
            marginBottom: 14,
            color: palette.softGold,
            fontSize: 24,
            fontWeight: 820,
            textTransform: "uppercase",
          }}
        >
          {eyebrow}
        </div>
      ) : null}
      <div
        style={{
          fontSize: title.length > 32 ? 61 : 76,
          lineHeight: 1.02,
          fontWeight: 850,
        }}
      >
        {title}
      </div>
      {body ? (
        <div
          style={{
            marginTop: 18,
            color: "rgba(255,255,255,0.76)",
            fontSize: 30,
            lineHeight: 1.2,
            fontWeight: 620,
          }}
        >
          {body}
        </div>
      ) : null}
    </div>
  );
};

export const PromoPhone: React.FC<{
  screen: ScreenName;
  scale?: number;
  x?: number;
  y?: number;
  rotate?: number;
  delay?: number;
}> = ({ screen, scale = 1, x = 0, y = 0, rotate = 0, delay = 0 }) => {
  const frame = useCurrentFrame();
  const local = frame - delay;
  const enter = spring({
    frame: local,
    fps: 30,
    config: { damping: 20, stiffness: 76, mass: 0.82 },
  });
  const float = Math.sin((frame + delay) / 38) * 8;

  return (
    <div
      style={{
        position: "absolute",
        left: "50%",
        top: 460 + y,
        width: 606,
        height: 1242,
        transform: `translateX(-50%) translateX(${x}px) translateY(${interpolate(
          enter,
          [0, 1],
          [120, float],
        )}px) scale(${scale}) rotate(${rotate}deg)`,
        opacity: interpolate(local, [0, 14], [0, 1], {
          extrapolateRight: "clamp",
        }),
        transformOrigin: "center",
        borderRadius: 90,
        padding: 18,
        background: "linear-gradient(145deg, #171b16, #030403)",
        boxShadow:
          "0 58px 120px rgba(0,0,0,0.50), 0 24px 64px rgba(242,180,74,0.13), inset 0 0 0 5px rgba(255,255,255,0.11)",
      }}
    >
      <div
        style={{
          position: "relative",
          width: "100%",
          height: "100%",
          overflow: "hidden",
          borderRadius: 70,
          background: palette.appBlack,
        }}
      >
        <div
          style={{
            position: "absolute",
            top: 18,
            left: "50%",
            width: 170,
            height: 38,
            borderRadius: 999,
            transform: "translateX(-50%)",
            background: "#020403",
            zIndex: 10,
          }}
        />
        <AppScreen name={screen} />
      </div>
    </div>
  );
};

export const ScreenStrip: React.FC<{
  screens: ScreenName[];
  top?: number;
}> = ({ screens, top = 835 }) => (
  <div
    style={{
      position: "absolute",
      top,
      left: 52,
      right: 52,
      display: "flex",
      justifyContent: "center",
      gap: 18,
    }}
  >
    {screens.map((screen, index) => (
      <PromoPhone
        key={screen}
        screen={screen}
        scale={0.34}
        x={(index - (screens.length - 1) / 2) * 350}
        y={-510}
        rotate={(index - 1.5) * 4}
        delay={index * 5}
      />
    ))}
  </div>
);

const AppScreen: React.FC<{ name: ScreenName }> = ({ name }) => {
  if (name === "home") return <HomeScreen />;
  if (name === "scanner") return <ScannerScreenPromo />;
  if (name === "scanResult") return <ScanResultScreen />;
  if (name === "editScan") return <EditScanScreen />;
  if (name === "savedTeas") return <SavedTeasScreen />;
  if (name === "timer") return <TimerScreenPromo />;
  return <ReviewScreenPromo />;
};

const ScreenBase: React.FC<{ children: ReactNode; teaIndex?: number }> = ({
  children,
  teaIndex = 0,
}) => {
  const tea = teas[teaIndex];

  return (
    <AbsoluteFill style={{ background: palette.appBlack, color: palette.white }}>
      <Img
        src={appAsset(tea.image)}
        style={{
          width: "100%",
          height: "100%",
          objectFit: "cover",
          filter: "blur(3px) saturate(0.84)",
          transform: "scale(1.12)",
          opacity: 0.86,
        }}
      />
      <AbsoluteFill
        style={{
          background:
            "linear-gradient(180deg, rgba(0,0,0,0.46), rgba(0,0,0,0.42), rgba(0,0,0,0.84))",
        }}
      />
      <AbsoluteFill
        style={{
          background: `radial-gradient(circle at 70% 18%, ${tea.tint}36, transparent 28%)`,
        }}
      />
      <div style={{ position: "relative", zIndex: 2, height: "100%" }}>
        {children}
      </div>
    </AbsoluteFill>
  );
};

const AppHeader: React.FC<{ subtitle?: string }> = ({
  subtitle = "Precise steeping for a cleaner, richer cup.",
}) => (
  <div style={{ padding: "76px 34px 0" }}>
    <div
      style={{
        fontFamily: "Georgia, 'Times New Roman', serif",
        fontSize: 50,
        fontWeight: 780,
        lineHeight: 1,
      }}
    >
      Tea Timer
    </div>
    <div
      style={{
        marginTop: 10,
        color: "rgba(255,255,255,0.70)",
        fontSize: 18,
        fontWeight: 560,
      }}
    >
      {subtitle}
    </div>
  </div>
);

const HomeScreen: React.FC = () => (
  <ScreenBase>
    <AppHeader />
    <div style={{ padding: "30px 28px 0" }}>
      <div style={{ display: "flex", gap: 11, justifyContent: "space-between" }}>
        {teas.map((tea) => (
          <div key={tea.id} style={{ textAlign: "center", width: 76 }}>
            <div
              style={{
                width: 68,
                height: 68,
                margin: "0 auto",
                overflow: "hidden",
                borderRadius: "50%",
                boxShadow:
                  tea.id === "green"
                    ? `0 0 0 4px ${tea.tint}, 0 14px 30px ${tea.tint}44`
                    : "0 10px 22px rgba(0,0,0,0.36)",
              }}
            >
              <Img src={appAsset(tea.image)} style={{ width: "100%", height: "100%", objectFit: "cover" }} />
            </div>
            <div
              style={{
                marginTop: 9,
                color: tea.id === "green" ? tea.tint : "rgba(255,255,255,0.62)",
                fontSize: 13,
                fontWeight: 780,
              }}
            >
              {tea.shortName}
            </div>
          </div>
        ))}
      </div>
      <TimerDial teaIndex={0} time="2:30" top={44} />
      <SavedTeasCard compact />
    </div>
  </ScreenBase>
);

const TimerDial: React.FC<{ teaIndex: number; time: string; top?: number }> = ({
  teaIndex,
  time,
  top = 42,
}) => {
  const frame = useCurrentFrame();
  const tea = teas[teaIndex];
  const radius = 156;
  const circumference = Math.PI * radius * 2;
  const progress = interpolate(frame, [0, 160], [0.96, 0.44], {
    extrapolateRight: "clamp",
  });

  return (
    <div style={{ marginTop: top, display: "flex", flexDirection: "column", alignItems: "center" }}>
      <div
        style={{
          position: "relative",
          width: 386,
          height: 386,
          borderRadius: "50%",
          background: "radial-gradient(circle, rgba(0,0,0,0.48), rgba(0,0,0,0.20))",
          boxShadow: "0 24px 60px rgba(0,0,0,0.42)",
          display: "flex",
          alignItems: "center",
          justifyContent: "center",
        }}
      >
        <svg width="386" height="386" viewBox="0 0 386 386">
          <circle cx="193" cy="193" r={radius} fill="none" stroke={`${tea.tint}42`} strokeWidth="14" />
          <circle
            cx="193"
            cy="193"
            r={radius}
            fill="none"
            stroke={tea.tint}
            strokeLinecap="round"
            strokeWidth="14"
            strokeDasharray={circumference}
            strokeDashoffset={circumference * (1 - progress)}
            transform="rotate(-90 193 193)"
          />
          <circle
            cx="193"
            cy="193"
            r={radius}
            fill="none"
            stroke={palette.gold}
            strokeWidth="4"
            strokeLinecap="round"
            strokeDasharray="50 930"
            transform={`rotate(${frame * 0.45 - 90} 193 193)`}
          />
        </svg>
        <div style={{ position: "absolute", textAlign: "center" }}>
          <div style={{ color: tea.tint, fontSize: 22, fontWeight: 820 }}>{teas[teaIndex].name}</div>
          <div
            style={{
              marginTop: 13,
              fontFamily: "Georgia, 'Times New Roman', serif",
              fontSize: 76,
              lineHeight: 1,
              fontWeight: 400,
            }}
          >
            {time}
          </div>
          <div style={{ marginTop: 10, color: tea.tint, fontSize: 18, fontWeight: 800 }}>
            {tea.temperature}
          </div>
        </div>
      </div>
      <div style={{ marginTop: 22, display: "flex", gap: 12, width: "100%" }}>
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
            fontSize: 20,
            fontWeight: 850,
          }}
        >
          Start
        </div>
        <div
          style={{
            width: 62,
            height: 62,
            borderRadius: "50%",
            background: "rgba(255,255,255,0.10)",
            display: "flex",
            alignItems: "center",
            justifyContent: "center",
            fontSize: 24,
          }}
        >
          ↻
        </div>
      </div>
    </div>
  );
};

const SavedTeasCard: React.FC<{ compact?: boolean }> = ({ compact = false }) => (
  <div style={{ marginTop: compact ? 26 : 34, padding: 20, ...cardStyle }}>
    <div style={{ color: palette.green, fontSize: 15, fontWeight: 850, textTransform: "uppercase" }}>
      Saved Teas
    </div>
    <div style={{ marginTop: 12, display: "grid", gap: 10 }}>
      {[
        ["Sencha Classic", "80 C", "2:30"],
        ["Earl Grey", "95 C", "3:30"],
      ].map(([name, temp, time]) => (
        <div
          key={name}
          style={{
            display: "flex",
            alignItems: "center",
            justifyContent: "space-between",
            padding: "12px 0",
            borderTop: "1px solid rgba(255,255,255,0.08)",
          }}
        >
          <div>
            <div style={{ fontSize: compact ? 18 : 22, fontWeight: 820 }}>{name}</div>
            <div style={{ marginTop: 5, color: "rgba(255,255,255,0.52)", fontSize: 13 }}>{temp}</div>
          </div>
          <div style={{ color: palette.green, fontSize: 19, fontWeight: 850 }}>{time}</div>
        </div>
      ))}
    </div>
  </div>
);

const ScannerScreenPromo: React.FC = () => (
  <ScreenBase teaIndex={2}>
    <div style={{ padding: "84px 34px 0", textAlign: "center" }}>
      <div
        style={{
          width: 106,
          height: 106,
          margin: "0 auto",
          borderRadius: "50%",
          background: `${teas[2].tint}20`,
          border: `1px solid ${teas[2].tint}60`,
          display: "flex",
          alignItems: "center",
          justifyContent: "center",
          color: teas[2].tint,
          fontSize: 46,
          fontWeight: 850,
        }}
      >
        ⌗
      </div>
      <div style={{ marginTop: 20, fontFamily: "Georgia, 'Times New Roman', serif", fontSize: 42, fontWeight: 780 }}>
        Scan Tea
      </div>
      <div style={{ margin: "12px auto 0", color: "rgba(255,255,255,0.68)", fontSize: 19, lineHeight: 1.28, width: 430 }}>
        Scan tea package text to detect tea type and suggest infusion settings.
      </div>
    </div>
    <div style={{ margin: "42px 34px 0", display: "grid", gap: 13 }}>
      {["Start Scan", "Demo Green", "Demo Black", "Create Personalized Tea"].map((label, index) => (
        <div
          key={label}
          style={{
            height: index === 0 ? 62 : 54,
            borderRadius: 999,
            background: index === 0 ? teas[2].tint : "rgba(255,255,255,0.10)",
            color: index === 0 ? "rgba(0,0,0,0.82)" : palette.white,
            display: "flex",
            alignItems: "center",
            justifyContent: "center",
            fontSize: 18,
            fontWeight: 850,
          }}
        >
          {label}
        </div>
      ))}
    </div>
  </ScreenBase>
);

const ScanResultScreen: React.FC = () => (
  <ScreenBase teaIndex={2}>
    <div style={{ padding: "84px 34px 0" }}>
      <div style={{ color: teas[2].tint, fontSize: 15, fontWeight: 850, textTransform: "uppercase" }}>
        Smart tea detection
      </div>
      <div style={{ marginTop: 14, fontSize: 42, fontWeight: 850 }}>Oolong Tea</div>
      <div style={{ marginTop: 10, color: "rgba(255,255,255,0.66)", fontSize: 19 }}>
        Suggested from package text.
      </div>
      <div style={{ marginTop: 34, padding: 24, ...cardStyle, border: `1px solid ${teas[2].tint}70` }}>
        <div style={{ color: "rgba(255,255,255,0.48)", fontSize: 13, fontWeight: 780 }}>
          SCAN RESULT
        </div>
        <div style={{ marginTop: 16, display: "grid", gap: 16 }}>
          {[
            ["Tea type", "Oolong"],
            ["Infusion", "3:30"],
            ["Water", "90 C"],
            ["Caffeine", "Medium"],
          ].map(([label, value]) => (
            <div key={label} style={{ display: "flex", justifyContent: "space-between", fontSize: 22 }}>
              <span style={{ color: "rgba(255,255,255,0.56)" }}>{label}</span>
              <span style={{ color: teas[2].tint, fontWeight: 850 }}>{value}</span>
            </div>
          ))}
        </div>
      </div>
      <div style={{ marginTop: 24, display: "flex", gap: 14 }}>
        <Pill label="Edit" />
        <Pill label="Save Tea" primary />
      </div>
    </div>
  </ScreenBase>
);

const EditScanScreen: React.FC = () => (
  <ScreenBase teaIndex={0}>
    <div style={{ padding: "84px 34px 0" }}>
      <div style={{ fontFamily: "Georgia, 'Times New Roman', serif", fontSize: 39, fontWeight: 780 }}>
        Personalized Tea
      </div>
      <div style={{ marginTop: 10, color: "rgba(255,255,255,0.64)", fontSize: 18 }}>
        Save a tea that is not in the database yet.
      </div>
      <div style={{ marginTop: 28, display: "grid", gap: 14 }}>
        {[
          ["Tea Name", "Jasmine Green"],
          ["Brand", "My tea shelf"],
          ["Tea Style", "Green"],
          ["Suggested Infusion", "2 min 30 sec"],
          ["Water C", "80"],
          ["Notes", "Floral, fresh, soft"],
        ].map(([label, value]) => (
          <div key={label} style={{ padding: 16, ...cardStyle }}>
            <div style={{ color: "rgba(255,255,255,0.44)", fontSize: 12, fontWeight: 850, textTransform: "uppercase" }}>
              {label}
            </div>
            <div style={{ marginTop: 8, color: label === "Tea Style" ? palette.green : palette.white, fontSize: 20, fontWeight: 820 }}>
              {value}
            </div>
          </div>
        ))}
      </div>
      <Pill label="Save Tea" primary top={24} />
    </div>
  </ScreenBase>
);

const SavedTeasScreen: React.FC = () => (
  <ScreenBase teaIndex={1}>
    <div style={{ padding: "84px 34px 0" }}>
      <div style={{ fontFamily: "Georgia, 'Times New Roman', serif", fontSize: 42, fontWeight: 780 }}>
        Saved Teas
      </div>
      <div style={{ marginTop: 10, color: "rgba(255,255,255,0.64)", fontSize: 18 }}>
        Your scanned and personalized timers.
      </div>
      <div style={{ marginTop: 32, display: "grid", gap: 14 }}>
        {[
          ["Sencha Classic", "Fresh · 80 C · Medium", "2:30", 0],
          ["Earl Grey", "Bold · 95 C · High", "3:30", 1],
          ["Oolong Tea", "Layered · 90 C · Medium", "3:30", 2],
          ["Chamomile Calm", "Calm · 100 C · None", "5:00", 4],
        ].map(([name, meta, time, teaIndex]) => {
          const tea = teas[Number(teaIndex)];
          return (
            <div key={String(name)} style={{ padding: 16, display: "flex", alignItems: "center", gap: 14, ...cardStyle }}>
              <div style={{ width: 58, height: 58, borderRadius: "50%", overflow: "hidden" }}>
                <Img src={appAsset(tea.image)} style={{ width: "100%", height: "100%", objectFit: "cover" }} />
              </div>
              <div style={{ flex: 1 }}>
                <div style={{ fontSize: 22, fontWeight: 850 }}>{name}</div>
                <div style={{ marginTop: 5, color: "rgba(255,255,255,0.54)", fontSize: 13 }}>{meta}</div>
              </div>
              <div style={{ color: tea.tint, fontSize: 20, fontWeight: 850 }}>{time}</div>
            </div>
          );
        })}
      </div>
    </div>
  </ScreenBase>
);

const TimerScreenPromo: React.FC = () => (
  <ScreenBase teaIndex={0}>
    <AppHeader subtitle="Green Tea is steeping." />
    <div style={{ padding: "18px 28px 0" }}>
      <TimerDial teaIndex={0} time="02:16" top={28} />
      <div style={{ marginTop: 26, padding: 18, display: "flex", gap: 14, alignItems: "center", ...cardStyle }}>
        <div style={{ width: 46, height: 46, borderRadius: "50%", background: `${palette.green}24`, color: palette.green, display: "flex", alignItems: "center", justifyContent: "center", fontSize: 24 }}>
          ✦
        </div>
        <div>
          <div style={{ fontSize: 18, fontWeight: 850 }}>Take a moment for yourself.</div>
          <div style={{ marginTop: 5, color: "rgba(255,255,255,0.58)", fontSize: 14 }}>
            Add a thought while your tea is brewing.
          </div>
        </div>
      </div>
    </div>
  </ScreenBase>
);

const ReviewScreenPromo: React.FC = () => (
  <ScreenBase teaIndex={0}>
    <div style={{ padding: "84px 34px 0" }}>
      <div style={{ fontFamily: "Georgia, 'Times New Roman', serif", fontSize: 42, fontWeight: 780 }}>
        Tea Moments
      </div>
      <div style={{ marginTop: 10, color: "rgba(255,255,255,0.64)", fontSize: 18 }}>
        Review the cups you want to remember.
      </div>
      <div style={{ marginTop: 25, display: "flex", padding: 5, borderRadius: 999, background: "rgba(255,255,255,0.10)" }}>
        {["Moments", "Stats", "Reviews"].map((tab, index) => (
          <div key={tab} style={{ flex: 1, padding: "10px 0", borderRadius: 999, textAlign: "center", background: index === 0 ? palette.green : "transparent", color: index === 0 ? "rgba(0,0,0,0.82)" : palette.mutedWhite, fontSize: 15, fontWeight: 850 }}>
            {tab}
          </div>
        ))}
      </div>
      <div style={{ marginTop: 24, display: "grid", gap: 14 }}>
        {[
          ["Green Tea", "Peaceful", "Today", "2:30"],
          ["Oolong", "Focused", "Yesterday", "3:30"],
          ["Herbal", "Cozy", "Mon", "5:00"],
        ].map(([tea, mood, date, time]) => (
          <div key={tea} style={{ padding: 18, ...cardStyle }}>
            <div style={{ display: "flex", justifyContent: "space-between", color: "rgba(255,255,255,0.46)", fontSize: 13, fontWeight: 780 }}>
              <span>{mood}</span>
              <span>{date}</span>
            </div>
            <div style={{ marginTop: 10, fontSize: 24, fontWeight: 850 }}>{tea}</div>
            <div style={{ marginTop: 6, color: palette.green, fontSize: 16, fontWeight: 800 }}>{time} infusion</div>
          </div>
        ))}
      </div>
      <div style={{ marginTop: 20, padding: 20, ...cardStyle, border: `1px solid ${palette.green}66` }}>
        <div style={{ color: palette.green, fontSize: 17, fontWeight: 850 }}>Green Tea Review</div>
        <div style={{ marginTop: 8, color: palette.softGold, fontSize: 27, letterSpacing: 2 }}>★★★★★</div>
        <div style={{ marginTop: 8, color: "rgba(255,255,255,0.62)", fontSize: 15 }}>
          Clean, bright, and exactly right.
        </div>
      </div>
    </div>
  </ScreenBase>
);

const Pill: React.FC<{ label: string; primary?: boolean; top?: number }> = ({
  label,
  primary = false,
  top = 0,
}) => (
  <div
    style={{
      marginTop: top,
      flex: 1,
      height: 58,
      borderRadius: 999,
      background: primary ? palette.green : "rgba(255,255,255,0.10)",
      color: primary ? "rgba(0,0,0,0.82)" : palette.white,
      display: "flex",
      alignItems: "center",
      justifyContent: "center",
      fontSize: 18,
      fontWeight: 850,
    }}
  >
    {label}
  </div>
);
