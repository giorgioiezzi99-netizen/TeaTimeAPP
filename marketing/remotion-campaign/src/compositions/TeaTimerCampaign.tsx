import {
  AbsoluteFill,
  Img,
  Sequence,
  interpolate,
  spring,
  staticFile,
  useCurrentFrame,
} from "remotion";
import {
  PromoBackdrop,
  PromoCaption,
  PromoPhone,
} from "../components/AppPromoScreens";
import { palette, teas } from "../components/TeaComponents";

const FadeScene: React.FC<{
  children: React.ReactNode;
  fadeOutAt?: number;
}> = ({ children, fadeOutAt = 130 }) => {
  const frame = useCurrentFrame();
  const opacity = interpolate(frame, [0, 12, fadeOutAt, fadeOutAt + 12], [0, 1, 1, 0], {
    extrapolateLeft: "clamp",
    extrapolateRight: "clamp",
  });

  return <AbsoluteFill style={{ opacity }}>{children}</AbsoluteFill>;
};

const HomeHeroScene: React.FC<{ title?: string; body?: string }> = ({
  title = "TeaTimer",
  body = "Perfect tea, every time.",
}) => (
  <PromoBackdrop image="warm-tea-table-bg.png" tint={teas[0].tint}>
    <PromoCaption
      eyebrow="iPhone tea timer"
      title={title}
      body={body}
      top={112}
      align="center"
    />
    <PromoPhone screen="home" scale={0.86} y={150} />
  </PromoBackdrop>
);

const CategoriesScene: React.FC = () => (
  <PromoBackdrop image="launch-lifestyle-bg.png" tint={teas[0].tint}>
    <PromoCaption
      eyebrow="Choose your tea"
      title="Green. Black. White. Oolong. Herbal."
      body="Pick the tea type, then start the right timer."
      top={104}
    />
    <PromoPhone screen="home" scale={0.72} x={-185} y={230} rotate={-7} />
    <PromoPhone screen="savedTeas" scale={0.66} x={205} y={286} rotate={7} delay={8} />
    <FloatingLabel text="Saved Teas" x={650} y={1260} />
    <FloatingLabel text="Tea categories" x={94} y={1340} />
  </PromoBackdrop>
);

const ScannerScene: React.FC = () => (
  <PromoBackdrop image="scanner-package-bg.png" tint={teas[2].tint}>
    <PromoCaption
      eyebrow="Smart tea detection"
      title="Scan the label."
      body="TeaTimer suggests the right brew timer."
      top={112}
    />
    <PromoPhone screen="scanner" scale={0.74} x={-130} y={250} rotate={-5} />
    <PromoPhone screen="scanResult" scale={0.72} x={190} y={210} rotate={5} delay={10} />
    <FloatingLabel text="Edit" x={122} y={1500} />
    <FloatingLabel text="Save Tea" x={706} y={1420} />
  </PromoBackdrop>
);

const ScanSaveScene: React.FC = () => (
  <PromoBackdrop image="scanner-package-bg.png" tint={teas[0].tint}>
    <PromoCaption
      eyebrow="After scanning"
      title="Edit, save, brew."
      body="Keep personalized timers ready for the next cup."
      top={104}
    />
    <PromoPhone screen="scanResult" scale={0.58} x={-285} y={330} rotate={-10} />
    <PromoPhone screen="editScan" scale={0.68} x={25} y={230} />
    <PromoPhone screen="savedTeas" scale={0.58} x={315} y={330} rotate={10} delay={8} />
  </PromoBackdrop>
);

const TimerReviewScene: React.FC = () => (
  <PromoBackdrop image="warm-tea-table-bg.png" tint={teas[0].tint}>
    <PromoCaption
      eyebrow="Brew and remember"
      title="Time the cup. Review the moment."
      body="Countdown, mood, notes, and ratings stay together."
      top={104}
    />
    <PromoPhone screen="timer" scale={0.78} x={-150} y={210} rotate={-5} />
    <PromoPhone screen="review" scale={0.70} x={190} y={280} rotate={6} delay={8} />
  </PromoBackdrop>
);

const EndCardScene: React.FC = () => {
  const frame = useCurrentFrame();
  const logoScale = spring({
    frame,
    fps: 30,
    config: { damping: 18, stiffness: 86 },
  });

  return (
    <PromoBackdrop image="hero-thumbnail-bg.png" tint={teas[0].tint}>
      <div
        style={{
          position: "absolute",
          inset: 0,
          background:
            "linear-gradient(180deg, rgba(0,0,0,0.10), rgba(0,0,0,0.22), rgba(0,0,0,0.78))",
        }}
      />
      <div
        style={{
          position: "absolute",
          left: 78,
          right: 78,
          top: 182,
          textAlign: "center",
          textShadow: "0 20px 56px rgba(0,0,0,0.46)",
        }}
      >
        <Img
          src={staticFile("/assets/app/teatimer-app-icon.png")}
          style={{
            width: 172,
            height: 172,
            borderRadius: 38,
            boxShadow: "0 30px 74px rgba(0,0,0,0.36)",
            transform: `scale(${interpolate(logoScale, [0, 1], [0.82, 1])})`,
          }}
        />
        <div
          style={{
            marginTop: 42,
            fontFamily: "Georgia, 'Times New Roman', serif",
            fontSize: 88,
            fontWeight: 780,
            lineHeight: 0.96,
          }}
        >
          TeaTimer
        </div>
        <div
          style={{
            marginTop: 22,
            color: palette.softGold,
            fontSize: 44,
            fontWeight: 820,
            lineHeight: 1.1,
          }}
        >
          Perfect tea, every time.
        </div>
        <div
          style={{
            marginTop: 28,
            color: "rgba(255,255,255,0.72)",
            fontSize: 27,
            fontWeight: 650,
          }}
        >
          Now testing on iPhone
        </div>
      </div>
      <PromoPhone screen="home" scale={0.46} x={0} y={840} delay={6} />
    </PromoBackdrop>
  );
};

const BumperScene: React.FC = () => {
  const frame = useCurrentFrame();
  const phoneX = interpolate(frame, [0, 42, 140, 180], [420, 0, 0, -420], {
    extrapolateLeft: "clamp",
    extrapolateRight: "clamp",
  });
  const logoOpacity = interpolate(frame, [84, 108], [0, 1], {
    extrapolateRight: "clamp",
  });

  return (
    <PromoBackdrop image="hero-thumbnail-bg.png" tint={teas[0].tint}>
      <PromoPhone screen="timer" scale={0.76} x={phoneX} y={190} />
      <div
        style={{
          position: "absolute",
          left: 74,
          right: 74,
          top: 120,
          textAlign: "center",
          textShadow: "0 18px 48px rgba(0,0,0,0.45)",
        }}
      >
        <div
          style={{
            fontSize: 66,
            lineHeight: 1.02,
            fontWeight: 860,
          }}
        >
          Stop guessing your tea time.
        </div>
      </div>
      <div
        style={{
          position: "absolute",
          left: 72,
          right: 72,
          bottom: 150,
          textAlign: "center",
          opacity: logoOpacity,
          textShadow: "0 18px 48px rgba(0,0,0,0.48)",
        }}
      >
        <div
          style={{
            fontFamily: "Georgia, 'Times New Roman', serif",
            fontSize: 78,
            fontWeight: 780,
          }}
        >
          TeaTimer
        </div>
        <div
          style={{
            marginTop: 14,
            color: palette.softGold,
            fontSize: 38,
            fontWeight: 820,
          }}
        >
          Perfect tea, every time.
        </div>
      </div>
    </PromoBackdrop>
  );
};

const FloatingLabel: React.FC<{ text: string; x: number; y: number }> = ({
  text,
  x,
  y,
}) => {
  const frame = useCurrentFrame();
  const opacity = interpolate(frame, [10, 24], [0, 1], {
    extrapolateRight: "clamp",
  });

  return (
    <div
      style={{
        position: "absolute",
        left: x,
        top: y,
        opacity,
        padding: "13px 18px",
        borderRadius: 999,
        background: "rgba(0,0,0,0.42)",
        border: "1px solid rgba(255,255,255,0.12)",
        color: palette.white,
        fontSize: 22,
        fontWeight: 780,
        boxShadow: "0 16px 40px rgba(0,0,0,0.25)",
      }}
    >
      {text}
    </div>
  );
};

export const TeaTimerAd15: React.FC = () => (
  <AbsoluteFill>
    <Sequence durationInFrames={90}>
      <FadeScene fadeOutAt={72}>
        <HomeHeroScene title="TeaTimer" body="Perfect tea, every time." />
      </FadeScene>
    </Sequence>
    <Sequence from={90} durationInFrames={120}>
      <FadeScene fadeOutAt={102}>
        <CategoriesScene />
      </FadeScene>
    </Sequence>
    <Sequence from={210} durationInFrames={120}>
      <FadeScene fadeOutAt={102}>
        <ScannerScene />
      </FadeScene>
    </Sequence>
    <Sequence from={330} durationInFrames={120}>
      <EndCardScene />
    </Sequence>
  </AbsoluteFill>
);

export const TeaTimerAd30: React.FC = () => (
  <AbsoluteFill>
    <Sequence durationInFrames={120}>
      <FadeScene fadeOutAt={102}>
        <HomeHeroScene
          title="A tea timer made for iPhone."
          body="Choose the tea. Start the right timer."
        />
      </FadeScene>
    </Sequence>
    <Sequence from={120} durationInFrames={150}>
      <FadeScene fadeOutAt={132}>
        <CategoriesScene />
      </FadeScene>
    </Sequence>
    <Sequence from={270} durationInFrames={150}>
      <FadeScene fadeOutAt={132}>
        <ScannerScene />
      </FadeScene>
    </Sequence>
    <Sequence from={420} durationInFrames={180}>
      <FadeScene fadeOutAt={160}>
        <ScanSaveScene />
      </FadeScene>
    </Sequence>
    <Sequence from={600} durationInFrames={150}>
      <FadeScene fadeOutAt={132}>
        <TimerReviewScene />
      </FadeScene>
    </Sequence>
    <Sequence from={750} durationInFrames={150}>
      <EndCardScene />
    </Sequence>
  </AbsoluteFill>
);

export const TeaTimerBumper6: React.FC = () => <BumperScene />;

export const TeaTimerThumbnailHero: React.FC = () => <EndCardScene />;

export const TeaTimerThumbnailScanner: React.FC = () => (
  <PromoBackdrop image="scanner-package-bg.png" tint={teas[2].tint}>
    <PromoCaption
      title="Scan your tea label."
      body="TeaTimer suggests the right brew timer."
      top={126}
      align="center"
    />
    <PromoPhone screen="scanResult" scale={0.76} y={238} />
  </PromoBackdrop>
);
