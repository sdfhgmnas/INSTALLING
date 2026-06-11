const app = document.getElementById("app");
const modalOverlay = document.getElementById("modalOverlay");
const modal = document.getElementById("modal");
const toast = document.getElementById("toast");

// App version — bump on every meaningful edit so deployed copies are
// visibly identifiable.
const APP_VERSION = "2.8.4";

const USERS = {
  akash: { password: "akash", role: "akash" },
  admin: { password: "password1", role: "admin" },
};

function validateLogin(username, password) {
  const user = USERS[username.toLowerCase().trim()];
  if (!user || user.password !== password) return null;
  return user.role;
}

let currentUser = null;
let view = "login";
let searchQuery = "";
let pendingFilter = "all";
let showCompleted = false;
let timelineQuery = "";
let simDbQuery = "";
let stockQuery = "";
let stockCategoryFilter = "all";
let installations = [];
let maintenanceRecords = [];
let sims = [];
let stockItems = [];
let stockTransactions = [];
let stockCategories = [];
let suppliers = [];
let deletionLog = [];
let simsTableReady = true;
let stockItemsTableReady = true;
let stockTxTableReady = true;
let stockCategoriesTableReady = true;
let suppliersTableReady = true;
let deletionLogTableReady = true;
let isLoadingData = false;
let lastSyncedAt = null;

// Realtime state
let realtimeChannel = null;
let realtimeStatus = "idle";
let refreshTimer = null;

/* ============================================================
   DELETION REASON PROMPT + AUDIT
   Every destructive action goes through promptForReason and is
   logged to deletion_log (visible to admin in the Deletions tab).
   ============================================================ */

function promptForReason({ title, message, confirmLabel = "Delete", placeholder = "Why are you deleting this?" }) {
  return new Promise((resolve) => {
    modal.innerHTML = `
      <h3>🗑️ ${escapeHtml(title)}</h3>
      ${message ? `<p class="modal-desc">${message}</p>` : ""}
      <div class="field">
        <label for="delReason">Reason for deletion <span class="required">*</span></label>
        <input type="text" id="delReason" autocomplete="off" placeholder="${escapeHtml(placeholder)}" />
        <p class="hint">This reason will be saved permanently in the audit log so admin can review what was deleted and why.</p>
      </div>
      <div class="modal-actions">
        <button type="button" class="btn btn-secondary" data-act="cancel">Cancel</button>
        <button type="button" class="btn btn-danger" data-act="confirm">${escapeHtml(confirmLabel)}</button>
      </div>
    `;
    modalOverlay.classList.remove("hidden");
    const input = modal.querySelector("#delReason");
    input?.focus();
    const done = (val) => {
      closeModal();
      resolve(val);
    };
    modal.querySelector('[data-act="cancel"]').onclick = () => done(null);
    modal.querySelector('[data-act="confirm"]').onclick = () => {
      const v = (input.value || "").trim();
      if (!v) {
        showToast("Please enter a reason for deletion.", true);
        return;
      }
      done(v);
    };
    input?.addEventListener("keydown", (e) => {
      if (e.key === "Escape") done(null);
      if (e.key === "Enter") {
        e.preventDefault();
        modal.querySelector('[data-act="confirm"]').click();
      }
    });
    modalOverlay.onclick = (e) => {
      if (e.target === modalOverlay) done(null);
    };
  });
}
