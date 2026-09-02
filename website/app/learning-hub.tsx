"use client";

import { useEffect, useMemo, useState } from "react";
import Link from "next/link";
import { ArrowRight, Check, Copy, ExternalLink, Play, Search } from "lucide-react";
import { Button } from "@/components/ui/button";
import { Dialog, DialogContent, DialogDescription, DialogHeader, DialogTitle } from "@/components/ui/dialog";
import { Input } from "@/components/ui/input";

type CatalogueEntry = {
  id: string;
  kind: "layout" | "feature";
  name: string;
  category: string;
  evidence: string;
  use: string;
  code: string;
  classes: string[];
  caveat: string;
  preview: string;
  snippet: string;
};

type Catalogue = {
  entries: CatalogueEntry[];
};

const layoutChoices = [
  { evidence: "One empirical figure", layout: "Text + figure", code: ".text-figure", id: "text-figure", description: "Use a short interpretation column and give the figure about 70% of the content area." },
  { evidence: "Dense or faceted figure", layout: "Wide figure", code: ".wide-figure", id: "wide-figure", description: "Use a narrow interpretation column and reserve nearly the full width for the figure." },
  { evidence: "Spatial result", layout: "Map + context", code: ".map-context", id: "map-context", description: "Keep the mapped area dominant and retain only the geographic context needed to interpret it." },
  { evidence: "Exact values", layout: "Scenario table", code: ".scenario-table", id: "scenario-table", description: "Use a focused full-width table when exact scenario values matter more than graphical shape." },
  { evidence: "Concept or mechanism", layout: "Concept + image", code: ".concept-image", id: "concept-image", description: "Pair the explanation with a photograph, schematic, map, or representative scientific figure." },
  { evidence: "Principal conclusion", layout: "Conclusion + figure", code: ".conclusion-figure", id: "conclusion-figure", description: "Keep the conclusion and its most relevant supporting visual visible during discussion." },
];

const workflow = [
  { number: "01", title: "Orient", description: "Read the analysis project and identify the available results, figures, and data-loading interfaces." },
  { number: "02", title: "Plan", description: "Agree on the audience, purpose, sequence of claims, supporting evidence, and output name." },
  { number: "03", title: "Build", description: "Generate displayed values and figures from stable project-relative inputs." },
  { number: "04", title: "Review", description: "Render the presentation, inspect every slide, correct layout problems, and check the final file size." },
];

const skills = [
  { name: "make-presentation", label: "Create", description: "Orient to a scientific project, agree on the slide plan, and build the presentation from rerenderable inputs." },
  { name: "review-presentation", label: "Review", description: "Render an existing presentation, inspect every slide, correct visual problems, and verify delivery files." },
  { name: "maintain-presentation-template", label: "Maintain", description: "Add layouts, update the catalogue and learning hub, and keep installer and validation checks aligned." },
];

function resolveEntryFromHash(entries: CatalogueEntry[]) {
  const prefix = "#layout/";
  if (!window.location.hash.startsWith(prefix)) return null;
  const id = decodeURIComponent(window.location.hash.slice(prefix.length));
  return entries.find((entry) => entry.id === id) ?? null;
}

export default function LearningHub() {
  const [entries, setEntries] = useState<CatalogueEntry[]>([]);
  const [loadError, setLoadError] = useState("");
  const [query, setQuery] = useState("");
  const [category, setCategory] = useState("All");
  const [selected, setSelected] = useState<CatalogueEntry | null>(null);
  const [copied, setCopied] = useState(false);

  useEffect(() => {
    let active = true;
    fetch("./layouts.json")
      .then((response) => {
        if (!response.ok) throw new Error("The layout catalogue could not be loaded.");
        return response.json() as Promise<Catalogue>;
      })
      .then((catalogue) => {
        if (!active) return;
        setEntries(catalogue.entries);
        setSelected(resolveEntryFromHash(catalogue.entries));
      })
      .catch((error: Error) => {
        if (active) setLoadError(error.message);
      });
    return () => {
      active = false;
    };
  }, []);

  useEffect(() => {
    const syncHash = () => setSelected(resolveEntryFromHash(entries));
    window.addEventListener("hashchange", syncHash);
    return () => window.removeEventListener("hashchange", syncHash);
  }, [entries]);

  const layouts = useMemo(() => entries.filter((entry) => entry.kind === "layout"), [entries]);
  const features = useMemo(() => entries.filter((entry) => entry.kind === "feature"), [entries]);
  const categories = useMemo(
    () => ["All", ...Array.from(new Set(layouts.map((layout) => layout.category)))],
    [layouts],
  );

  const visibleLayouts = useMemo(() => {
    const normalizedQuery = query.trim().toLowerCase();
    return layouts.filter((layout) => {
      const inCategory = category === "All" || layout.category === category;
      const searchable = [layout.name, layout.use, layout.evidence, layout.code, layout.category, ...layout.classes].join(" ").toLowerCase();
      return inCategory && (!normalizedQuery || searchable.includes(normalizedQuery));
    });
  }, [layouts, query, category]);

  function openEntry(entry: CatalogueEntry) {
    setCopied(false);
    setSelected(entry);
    window.history.replaceState(null, "", `#layout/${encodeURIComponent(entry.id)}`);
  }

  function closeEntry() {
    setSelected(null);
    setCopied(false);
    window.history.replaceState(null, "", "#layouts");
  }

  async function copySnippet() {
    if (!selected) return;
    await navigator.clipboard.writeText(selected.snippet);
    setCopied(true);
    window.setTimeout(() => setCopied(false), 1800);
  }

  return (
    <main>
      <header className="site-header">
        <Link className="brand" href="#top" aria-label="Presentation template home">
          <span className="brand-mark">IMR</span>
          <span>Presentation template</span>
        </Link>
        <nav aria-label="Primary navigation">
          <Link href="#choose">Choose a layout</Link>
          <Link href="#layouts">Layouts</Link>
          <Link href="#start">Get started</Link>
          <a href="https://github.com/DeepWaterIMR/presentation-template">GitHub</a>
        </nav>
      </header>

      <section className="hero" id="top">
        <div className="hero-copy">
          <p className="eyebrow">Quarto layouts for scientific presentations</p>
          <h1>Match each scientific claim with an appropriate slide layout.</h1>
          <p className="hero-lead">The template provides predefined layouts, reproducible figure workflows, and rendering checks for academic presentations.</p>
          <div className="hero-actions">
            <Link className="button button-primary" href="#layouts">Browse layouts <ArrowRight aria-hidden="true" /></Link>
            <Link className="button button-secondary" href="./demo/presentation.html"><Play aria-hidden="true" /> Open sampler</Link>
            <a className="text-link" href="https://github.com/DeepWaterIMR/presentation-template"><ExternalLink aria-hidden="true" /> View repository</a>
          </div>
          <div className="hero-feature-points" aria-label="Template features">
            <span>Full-sentence message titles</span>
            <span>Figures generated from analysis outputs</span>
            <span>Rendered-slide review</span>
          </div>
        </div>
        <div className="hero-preview" aria-label="Example scientific slide preview">
          <div className="slide-preview">
            <div className="slide-title">The fitted trajectories support the main interpretation.</div>
            <div className="slide-rule" />
            <div className="slide-body">
              <div className="slide-notes">
                <span />
                <span />
                <strong>State only the interpretation needed to read the figure.</strong>
              </div>
              <svg viewBox="0 0 360 180" aria-hidden="true">
                <path d="M24 132 C72 112 78 84 122 94 S185 44 232 67 S300 42 336 31" />
                <path className="coral" d="M24 45 C66 63 91 48 126 74 S190 93 225 78 S286 118 336 105" />
                <line x1="24" x2="336" y1="90" y2="90" />
              </svg>
            </div>
            <div className="slide-section">RESULTS</div>
          </div>
        </div>
      </section>

      <section className="section choice-section" id="choose">
        <div className="section-heading">
          <p className="eyebrow">Select a layout</p>
          <h2>Use the claim and its supporting evidence to select the composition.</h2>
          <p>Identify the figure, image, table, or explanation that supports the slide title, then choose a layout that gives it sufficient space.</p>
        </div>
        <div className="choice-grid">
          {layoutChoices.map((choice) => (
            <button className="choice-card" key={choice.id} type="button" onClick={() => {
              const entry = entries.find((candidate) => candidate.id === choice.id);
              if (entry) openEntry(entry);
            }}>
              <span>{choice.evidence}</span>
              <h3>{choice.layout}</h3>
              <code>{choice.code}</code>
              <p>{choice.description}</p>
            </button>
          ))}
        </div>
      </section>

      <section className="section catalogue-section" id="layouts">
        <div className="catalogue-heading">
          <div className="section-heading">
            <p className="eyebrow">Slide layout catalogue</p>
            <h2>Each layout is shown with a rendered example and its Quarto source.</h2>
            <p>The displayed name and code refer to the same composition, so a layout can be requested unambiguously.</p>
          </div>
          <Link className="text-link" href="./demo/presentation.html">Open all {entries.length || 21} examples <Play aria-hidden="true" /></Link>
        </div>

        <div className="catalogue-controls">
          <div className="search-field">
            <Search aria-hidden="true" />
            <label className="sr-only" htmlFor="layout-search">Search slide layouts</label>
            <Input id="layout-search" value={query} onChange={(event) => setQuery(event.target.value)} placeholder="Search layouts, evidence types, or classes" />
          </div>
          <div className="category-filters" aria-label="Filter layouts by category">
            {categories.map((name) => (
              <Button key={name} variant={category === name ? "default" : "outline"} size="sm" onClick={() => setCategory(name)} aria-pressed={category === name}>{name}</Button>
            ))}
          </div>
        </div>

        {loadError ? <p className="state-message error-message">{loadError}</p> : null}
        {!loadError && !entries.length ? <p className="state-message">Loading the rendered layout catalogue…</p> : null}
        {layouts.length > 0 && visibleLayouts.length === 0 ? <p className="state-message">No layouts match this search. Try another evidence type or category.</p> : null}

        <div className="layout-grid">
          {visibleLayouts.map((layout) => (
            <button className="layout-card" key={layout.id} type="button" onClick={() => openEntry(layout)} aria-label={`Inspect ${layout.name}`}>
              <span className="layout-image">
                {/* oxlint-disable-next-line next/no-img-element */}
                <img src={`./${layout.preview}`} alt="" loading="lazy" />
              </span>
              <span className="layout-content">
                <span className="tag">{layout.category}</span>
                <span className="layout-title">{layout.name}</span>
                <code className="layout-code">{layout.code}</code>
                <span className="layout-use">{layout.use}</span>
                <span className="layout-open">Inspect layout <ArrowRight aria-hidden="true" /></span>
              </span>
            </button>
          ))}
        </div>
      </section>

      <section className="section features-section" id="features">
        <div className="section-heading">
          <p className="eyebrow">Features and modifiers</p>
          <h2>Rendering features are documented separately from slide layouts.</h2>
          <p>These examples cover fragments, emphasis, background images, custom figure fonts, and table density. They modify a layout rather than replace one.</p>
        </div>
        <div className="feature-grid">
          {features.map((feature) => (
            <button className="feature-card" key={feature.id} type="button" onClick={() => openEntry(feature)} aria-label={`Inspect ${feature.name}`}>
              <span className="tag">{feature.category}</span>
              <span className="feature-title">{feature.name}</span>
              <code>{feature.code}</code>
              <span>{feature.use}</span>
              <span className="layout-open">Inspect feature <ArrowRight aria-hidden="true" /></span>
            </button>
          ))}
        </div>
      </section>

      <section className="section workflow-section" id="start">
        <div className="section-heading">
          <p className="eyebrow">Reproducible workflow</p>
          <h2>Presentation inputs can remain connected to the analysis project.</h2>
          <p>The template separates scientific computation from presentation-specific composition while allowing displayed results to be regenerated.</p>
        </div>
        <div className="workflow-grid">
          {workflow.map((step) => (
            <article className="workflow-step" key={step.number}>
              <span>{step.number}</span>
              <h3>{step.title}</h3>
              <p>{step.description}</p>
            </article>
          ))}
        </div>
        <div className="quickstart-grid">
          <article className="quickstart-card featured">
            <p className="eyebrow">Agent-assisted</p>
            <h3>Begin with the analysis context and an agreed slide plan.</h3>
            <p>Provide the template URL, analysis project, and destination folder. The agent reviews the project, drafts the slide plan, and waits for approval before building the presentation.</p>
            <pre><code>Use https://github.com/DeepWaterIMR/presentation-template to start a presentation in docs/presentation. Review the analysis first, prepare slide-plan.md, and wait for approval before building.</code></pre>
          </article>
          <article className="quickstart-card">
            <p className="eyebrow">Manual install</p>
            <h3>Install the template into an existing project.</h3>
            <pre><code>{`Rscript install_into_project.R \\
  --target "/path/to/project"`}</code></pre>
            <p>The default destination is <code>docs/presentation/</code>. Existing project-level agent guidance is not overwritten.</p>
          </article>
        </div>
      </section>

      <section className="section skills-section" id="skills">
        <div className="section-heading">
          <p className="eyebrow">Focused agent skills</p>
          <h2>Task-specific procedures are separated from stable presentation rules.</h2>
          <p>This limits automatic routing to the procedures relevant to creating, reviewing, or maintaining a presentation.</p>
        </div>
        <div className="skills-grid">
          {skills.map((skill) => (
            <article className="skill-card" key={skill.name}>
              <span className="skill-label">{skill.label}</span>
              <code>{skill.name}</code>
              <p>{skill.description}</p>
            </article>
          ))}
        </div>
      </section>

      <section className="section contribution-panel">
        <div>
          <p className="eyebrow">Contribute</p>
          <h2>New layouts require a source example, catalogue record, rendered preview, and validation.</h2>
        </div>
        <div className="contribution-actions">
          <a className="button button-primary" href="https://github.com/DeepWaterIMR/presentation-template/blob/main/CONTRIBUTING.md">Contribution guide <ArrowRight aria-hidden="true" /></a>
          <a className="button button-secondary" href="https://github.com/DeepWaterIMR/presentation-template/issues">Report an issue <ExternalLink aria-hidden="true" /></a>
        </div>
      </section>

      <footer>
        <span>DeepWaterIMR presentation template</span>
        <span>Quarto source · Self-contained HTML · MIT-licensed code</span>
      </footer>

      <Dialog open={Boolean(selected)} onOpenChange={(open) => { if (!open) closeEntry(); }}>
        {selected ? (
          <DialogContent className="layout-dialog">
            <DialogHeader>
              <div className="dialog-heading-row">
                <span className="tag">{selected.kind === "layout" ? selected.category : "Feature"}</span>
                <code className="class-list">{selected.code}</code>
              </div>
              <DialogTitle>{selected.name}</DialogTitle>
              <DialogDescription>{selected.use}</DialogDescription>
            </DialogHeader>
            <div className="dialog-grid">
              <div className="dialog-preview">
                {/* oxlint-disable-next-line next/no-img-element */}
                <img src={`./${selected.preview}`} alt={`Rendered example of ${selected.name}`} />
                <div className="dialog-facts">
                  <div><span>Evidence or explanation</span><strong>{selected.evidence}</strong></div>
                  <div><span>Consideration</span><strong>{selected.caveat}</strong></div>
                </div>
              </div>
              <div className="snippet-panel">
                <div className="snippet-header">
                  <span>Quarto source</span>
                  <Button size="sm" variant="outline" onClick={copySnippet}>{copied ? <Check aria-hidden="true" /> : <Copy aria-hidden="true" />}{copied ? "Copied" : "Copy"}</Button>
                </div>
                <pre><code>{selected.snippet}</code></pre>
                <span className="copy-status" aria-live="polite">{copied ? `${selected.kind === "layout" ? "Layout" : "Feature"} source copied to the clipboard.` : ""}</span>
              </div>
            </div>
          </DialogContent>
        ) : null}
      </Dialog>
    </main>
  );
}
