const form = document.querySelector("#waitlist-form");
const emailInput = document.querySelector("#email");
const statusText = document.querySelector("#form-status");

form?.addEventListener("submit", (event) => {
  event.preventDefault();

  const email = emailInput.value.trim();
  if (!emailInput.checkValidity()) {
    statusText.textContent = "Enter a valid email to open the waitlist message.";
    emailInput.focus();
    return;
  }

  const subject = encodeURIComponent("TeaTimer waitlist");
  const body = encodeURIComponent(`Hi TeaTimer team,\n\nPlease add me to the waitlist: ${email}\n`);

  statusText.textContent = "Opening your email app to join the waitlist.";
  window.location.href = `mailto:hello@teatimer.app?subject=${subject}&body=${body}`;
});
