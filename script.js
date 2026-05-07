const nav = document.querySelector("nav");
const navInner = nav?.querySelector(":scope > div");
const waitlistForm = document.querySelector("#waitlist form");

let lastScrollY = window.scrollY;

function setScrolledNav() {
  if (!nav || !navInner) return;

  const y = window.scrollY;
  const isScrolled = y > 40;
  const isHidden = y > 120 && y > lastScrollY;

  nav.classList.toggle("-translate-y-full", isHidden);
  nav.classList.toggle("opacity-0", isHidden);
  nav.classList.toggle("translate-y-0", !isHidden);
  nav.classList.toggle("opacity-100", !isHidden);

  navInner.classList.toggle("max-w-6xl", isScrolled);
  navInner.classList.toggle("mt-3", isScrolled);
  navInner.classList.toggle("py-3", isScrolled);
  navInner.classList.toggle("rounded-2xl", isScrolled);
  navInner.classList.toggle("border", isScrolled);
  navInner.classList.toggle("border-white/10", isScrolled);
  navInner.classList.toggle("bg-[oklch(0.16_0.04_150/0.75)]", isScrolled);
  navInner.classList.toggle("backdrop-blur-2xl", isScrolled);
  navInner.classList.toggle("shadow-[0_20px_60px_-30px_oklch(0_0_0/0.6)]", isScrolled);

  navInner.classList.toggle("max-w-[1600px]", !isScrolled);
  navInner.classList.toggle("mt-0", !isScrolled);
  navInner.classList.toggle("py-6", !isScrolled);
  navInner.classList.toggle("bg-transparent", !isScrolled);

  lastScrollY = y;
}

window.addEventListener("scroll", setScrolledNav, { passive: true });
setScrolledNav();

waitlistForm?.addEventListener("submit", (event) => {
  event.preventDefault();
  const note = waitlistForm.nextElementSibling;
  if (note) {
    note.textContent = "Thanks. Email capture is not connected yet.";
  }
});
