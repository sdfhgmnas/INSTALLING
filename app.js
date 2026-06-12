    }
    try {
      await insertStockCategory(name);
      await refreshAllData();
      closeModal();
      openCategoryManager();
    } catch (err) {
      showToast(err.message || "Add failed.", true);
    }
  }
  modal.querySelector("#addCatBtn").onclick = addNewCategory;
  modal.querySelector("#newCatName").addEventListener("keydown", (e) => {
    if (e.key === "Enter") {
      e.preventDefault();
      addNewCategory();
    }
  });
}

function openSupplierManager() {
  const sups = loadSuppliers();
  const itemsBySupplier = new Map();
  for (const it of loadStockItems()) {
    if (!it.supplier) continue;
    itemsBySupplier.set(it.supplier, (itemsBySupplier.get(it.supplier) || 0) + 1);
  }
  function rowHtml(sup) {
    const inUse = itemsBySupplier.get(sup.name) || 0;
    return `
      <div class="cat-row">
        <span class="supplier-pill">${escapeHtml(sup.name)}</span>
        <span class="cat-usage">${inUse > 0 ? `${inUse} item${inUse === 1 ? "" : "s"}` : "not in use"}</span>
        <button type="button" class="btn btn-danger btn-sm sup-delete" data-id="${escapeHtml(sup.id)}" ${inUse > 0 ? "disabled" : ""} title="${inUse > 0 ? "Items use this supplier — clear them first" : "Delete this supplier"}">Delete</button>
      </div>`;
  }
  modal.innerHTML = `
    <h3>🏷️ Manage suppliers</h3>
    <p class="modal-desc">Add suppliers or remove ones you don't use. Suppliers that have items can't be deleted until those items are reassigned.</p>
    <div class="cat-add-row">
      <input type="text" id="newSupName" autocomplete="off" placeholder="Supplier name (e.g. ABC Telecom)" />
      <button type="button" class="btn btn-primary btn-sm" id="addSupBtn">+ Add</button>
    </div>
    <div class="cat-list">
      ${sups.length ? sups.map(rowHtml).join("") : `<p class="muted">No suppliers yet. Add one above.</p>`}
    </div>
    <div class="modal-actions" style="margin-top: 1rem;">
      <button type="button" class="btn btn-secondary" data-act="cancel">Close</button>
    </div>
  `;
  modalOverlay.classList.remove("hidden");
  modalOverlay.onclick = (e) => {
    if (e.target === modalOverlay) closeModal();
  };
  modal.querySelector('[data-act="cancel"]').onclick = closeModal;

  modal.querySelectorAll(".sup-delete").forEach((btn) => {
    if (btn.disabled) return;
    btn.addEventListener("click", async () => {
      const id = btn.dataset.id;
      const sup = suppliers.find((s) => s.id === id);
      if (!sup) return;
      const ok = await showConfirm({
        title: "Delete supplier?",
        message: `Remove "${sup.name}" from the supplier list?`,
        confirmLabel: "Delete",
        danger: true,
      });
      if (!ok) return;
      try {
        await deleteSupplier(id);
        await refreshAllData();
        closeModal();
        openSupplierManager();
      } catch (err) {
        showToast(err.message || "Delete failed.", true);
      }
    });
  });

  async function addNewSupplier() {
    const name = modal.querySelector("#newSupName").value.trim();
    if (!name) {
      showToast("Type a supplier name first.", true);
      return;
    }
    try {
      await insertSupplier(name);
      await refreshAllData();
      closeModal();
      openSupplierManager();
    } catch (err) {
      showToast(err.message || "Add failed.", true);
    }
  }
  modal.querySelector("#addSupBtn").onclick = addNewSupplier;
  modal.querySelector("#newSupName").addEventListener("keydown", (e) => {
    if (e.key === "Enter") {
      e.preventDefault();
      addNewSupplier();
    }
  });
}

function render() {
  switch (view) {
    case "login":
      renderLogin();
      break;
    case "akash-home":
      renderAkashHome();
      break;
    case "install":
      renderInstallForm();
      break;
    case "repair":
      renderRepairForm();
      break;
    case "dashboard":
      renderDashboard();
      break;
    case "installations":
      renderInstallationsPage();
      break;
    case "repairs":
      renderRepairsPage();
      break;
    case "pending":
      renderPendingPage();
      break;
    case "sim-upload":
      renderSimUpload();
      break;
    case "sim-db":
      renderSimDb();
      break;
    case "stock":
      renderStockPage();
      break;
    case "deletions":
      renderDeletionsPage();
      break;
    case "timeline":
      renderTimeline();
      break;
    // Legacy aliases
    case "admin":
      renderDashboard();
      break;
    default:
      renderLogin();
  }
}


async function initApp() {
  if (!isSupabaseConfigured()) {
    renderConfigMissing();
    return;
  }
  try {
    initDb();
    render();
  } catch (err) {
    app.innerHTML = `
      ${renderHeader("GPS Maintenance Tracker", "Error")}
      <main class="main centered">
        <section class="card login-card"><h2>Could not start app</h2><p class="login-desc">${escapeHtml(err.message)}</p></section>
      </main>
    `;
  }
}

initApp();
