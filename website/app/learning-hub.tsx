"use client";

import { useEffect, useMemo, useState } from "react";
import Link from "next/link";
import { ArrowRight, Check, Copy, ExternalLink, Play, Search } from "lucide-react";
import { Button } from "@/components/ui/button";
import { Dialog, DialogContent, DialogDescription, DialogHeader, DialogTitle } from "@/components/ui/dialog";
import { Input } from "@/components/ui/input";

type Pattern = {
  id: string;
  title: string;
  category: string;
  proofObject: string;
  use: string;
  classes: string[];
  caveat: string;
  preview: string;
  snippet: string;
};

type Catalogue = {
  patterns: Pattern[];
};

const proofChoices = [
  { proof: "One result", pattern: "Text + figure", description: "Keep the interpretation visible beside a dominant chart or map." },
  { proof: "Exact values", pattern: "Decision table", description: "Use a narrow table when scenario values matter more than shape." },
  { proof: "A sequence", pattern: "Progressive reveal", description: "Swap or advance figures in place without moving the audience's eye." },
  { proof: "A system", pattern: "Concept diagram", description: "Build an editable hub, flow, or labelled grid directly in HTML and CSS." },
];

const workflow = [
  { number: "01", title: "Orient", description: "Read the analysis project and locate the compact result objects." },
  { number: "02", title: "Plan", description: "Agree on audience, purpose, claim spine, proof objects, and output name." },
  { number: "03", title: "Build", description: "Regenerate every value and figure from stable project-relative inputs." },
  { number: "04", title: "Review", description: "Render, inspect screenshots, correct layout, and check the final file size." },
];

const skills = [
  { name: "make-presentation", label: "Create", description: "Orient to a scientific project, agree on the slide plan, then build from rerenderable inputs." },
  { name: "review-presentation", label: "Review", description: "Render an existing deck, inspect every slide, fix visual problems, and verify delivery artifacts." },
  { name: "maintain-presentation-template", label: "Maintain", description: "Add patterns, update the catalogue and learning hub, and keep installer and CI contracts aligned." },
];

function resolvePatternFromHash(patterns: Pattern[]) {
  const prefix = "#pattern/";
  if (!window.location.hash.startsWith(prefix)) return null;
  const id = decodeURIComponent(window.location.hash.slice(prefix.length));
  return patterns.find((pattern) => pattern.id === id) ?? null;
}

export default function LearningHub() {
  const [patterns, setPatterns] = useState<Pattern[]>([]);
  const [loadError, setLoadError] = useState("");
  const [query, setQuery] = useState("");
  const [category, setCategory] = useState("All");
  const [selected, setSelected] = useState<Pattern | null>(null);
  const [copied, setCopied] = useState(false);

  useEffect(() => {
    let active = true;
    fetch("./patterns.json")
      .then((response) => {
        if (!response.ok) throw new Error("The pattern catalogue could not be loaded.");
        return response.json() as Promise<Catalogue>;
      })
      .then((catalogue) => {
        if (!active) return;
        setPatterns(catalogue.patterns);
        setSelected(resolvePatternFromHash(catalogue.patterns));
      })
      .catch((error: Error) => {
        if (active) setLoadError(error.message);
      });
    return () => {
      active = false;
    };
  }, []);

  useEffect(() => {
    const syncHash = () => setSelected(resolvePatternFromHash(patterns));
    window.addEventListener("hashchange", syncHash);
    return () => window.removeEventListener("hashchange", syncHash);
  }, [patterns]);

  const categories = useMemo(
    () => ["All", ...Array.from(new Set(patterns.map((pattern) => pattern.category)))],
    [patterns],
  );

  const visiblePatterns = useMemo(() => {
    const normalizedQuery = query.trim().toLowerCase();
    return patterns.filter((pattern) => {
      const inCategory = category === "All" || pattern.category === category;
      const searchable = [pattern.title, pattern.use, pattern.proofObject, pattern.category, ...pattern.classes].join(" ").toLowerCase();
      return inCategory && (!normalizedQuery || searchable.includes(normalizedQuery));
    });
  }, [patterns, query, category]);

  function openPattern(pattern: Pattern) {
    setCopied(false);
    setSelected(pattern);
    window.history.replaceState(null, "", `#pattern/${encodeURIComponent(pattern.id)}`);
  }

  function closePattern() {
    setSelected(null);
    setCopied(false);
    window.history.replaceState(null, "", "#patterns");
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
          <Link href="#patterns">Patterns</Link>
          <Link href="#start">Get started</Link>
          <a href="https://github.com/DeepWaterIMR/presentation-template">GitHub</a>
        </nav>
      </header>

      <section className="hero" id="top">
        <div className="hero-copy">
          <p className="eyebrow">Scientific presentations, built to rerender</p>
          <h1>Choose the proof. Then choose the slide.</h1>
          <p className="hero-lead">A practical Quarto starter for scientists who want clear claims, reproducible figures, and layouts that hold up in the meeting room.</p>
          <div className="hero-actions">
            <Link className="button button-primary" href="#patterns">Browse patterns <ArrowRight aria-hidden="true" /></Link>
            <Link className="button button-secondary" href="./demo/presentation.html"><Play aria-hidden="true" /> Open sampler</Link>
            <a className="text-link" href="https://github.com/DeepWaterIMR/presentation-template"><ExternalLink aria-hidden="true" /> View repository</a>
          </div>
          <div className="hero-proof-points" aria-label="Template guarantees">
            <span>One claim per slide</span>
            <span>Analysis-backed figures</span>
            <span>Visual QA built in</span>
          </div>
        </div>
        <div className="hero-proof" aria-label="Example scientific slide preview">
          <div className="slide-preview">
            <div className="slide-title">Trajectories should carry the argument</div>
            <div className="slide-rule" />
            <div className="slide-body">
              <div className="slide-notes">
                <span />
                <span />
                <span />
                <strong>Use one takeaway beside the proof.</strong>
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
          <p className="eyebrow">Choose by proof object</p>
          <h2>Start with what the audience must see.</h2>
          <p>The layout follows the evidence. Pick the proof object first, then keep everything else subordinate.</p>
        </div>
        <div className="choice-grid">
          {proofChoices.map((choice) => (
            <article className="choice-card" key={choice.proof}>
              <span>{choice.proof}</span>
              <h3>{choice.pattern}</h3>
              <p>{choice.description}</p>
            </article>
          ))}
        </div>
      </section>

      <section className="section catalogue-section" id="patterns">
        <div className="catalogue-heading">
          <div className="section-heading">
            <p className="eyebrow">Complete pattern library</p>
            <h2>Every supported slide pattern, rendered and ready to copy.</h2>
            <p>Browse by task, inspect the real sampler source, and open any example as a stable deep link.</p>
          </div>
          <Link className="text-link" href="./demo/presentation.html">Open all {patterns.length || 21} slides <Play aria-hidden="true" /></Link>
        </div>

        <div className="catalogue-controls">
          <div className="search-field">
            <Search aria-hidden="true" />
            <label className="sr-only" htmlFor="pattern-search">Search slide patterns</label>
            <Input id="pattern-search" value={query} onChange={(event) => setQuery(event.target.value)} placeholder="Search patterns, proof objects, or classes" />
          </div>
          <div className="category-filters" aria-label="Filter by category">
            {categories.map((name) => (
              <Button key={name} variant={category === name ? "default" : "outline"} size="sm" onClick={() => setCategory(name)} aria-pressed={category === name}>{name}</Button>
            ))}
          </div>
        </div>

        {loadError ? <p className="state-message error-message">{loadError}</p> : null}
        {!loadError && !patterns.length ? <p className="state-message">Loading the rendered pattern catalogue…</p> : null}
        {patterns.length && !visiblePatterns.length ? <p className="state-message">No patterns match this search. Try another proof object or category.</p> : null}

        <div className="pattern-grid">
          {visiblePatterns.map((pattern) => (
            <button className="pattern-card" key={pattern.id} type="button" onClick={() => openPattern(pattern)} aria-label={`Inspect ${pattern.title}`}>
              <span className="pattern-image">
                {/* oxlint-disable-next-line next/no-img-element */}
                <img src={`./${pattern.preview}`} alt="" loading="lazy" />
              </span>
              <span className="pattern-content">
                <span className="tag">{pattern.category}</span>
                <span className="pattern-title">{pattern.title}</span>
                <span className="pattern-use">{pattern.use}</span>
                <span className="pattern-open">Inspect pattern <ArrowRight aria-hidden="true" /></span>
              </span>
            </button>
          ))}
        </div>
      </section>

      <section className="section workflow-section" id="start">
        <div className="section-heading">
          <p className="eyebrow">Reproducible workflow</p>
          <h2>The deck stays connected to the analysis.</h2>
          <p>The template separates scientific computation from presentation logic while keeping every displayed result rerenderable.</p>
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
            <h3>Start with the conversation, not the slide file.</h3>
            <p>Give the agent the template URL, analysis project, and destination folder. It will learn the project, draft the slide plan, and wait for approval before building.</p>
            <pre><code>Use https://github.com/DeepWaterIMR/presentation-template to start a presentation in docs/presentation. Familiarize yourself with the analysis first, prepare slide-plan.md, and wait for approval before building.</code></pre>
          </article>
          <article className="quickstart-card">
            <p className="eyebrow">Manual install</p>
            <h3>Install the scaffold into an existing project.</h3>
            <pre><code>{`Rscript install_into_project.R \\
  --target "/path/to/project"`}</code></pre>
            <p>The default destination is <code>docs/presentation/</code>. Existing project-level agent guidance is never overwritten.</p>
          </article>
        </div>
      </section>

      <section className="section skills-section" id="skills">
        <div className="section-heading">
          <p className="eyebrow">Focused agent skills</p>
          <h2>Task workflows are skills. Stable rules stay in the repository contract.</h2>
          <p>This keeps automatic discovery precise without loading rendering and maintenance procedures into every session.</p>
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
          <p className="eyebrow">Improve the template</p>
          <h2>New patterns should arrive with a rendered example, catalogue entry, and validation.</h2>
        </div>
        <div className="contribution-actions">
          <a className="button button-primary" href="https://github.com/DeepWaterIMR/presentation-template/blob/main/CONTRIBUTING.md">Contribution guide <ArrowRight aria-hidden="true" /></a>
          <a className="button button-secondary" href="https://github.com/DeepWaterIMR/presentation-template/issues">Report an issue <ExternalLink aria-hidden="true" /></a>
        </div>
      </section>

      <footer>
        <span>DeepWaterIMR presentation template</span>
        <span>Quarto source · Self-contained HTML · MIT licensed code</span>
      </footer>

      <Dialog open={Boolean(selected)} onOpenChange={(open) => { if (!open) closePattern(); }}>
        {selected ? (
          <DialogContent className="pattern-dialog">
            <DialogHeader>
              <div className="dialog-heading-row">
                <span className="tag">{selected.category}</span>
                <span className="class-list">{selected.classes.map((className) => `.${className}`).join(" · ")}</span>
              </div>
              <DialogTitle>{selected.title}</DialogTitle>
              <DialogDescription>{selected.use}</DialogDescription>
            </DialogHeader>
            <div className="dialog-grid">
              <div className="dialog-preview">
                {/* oxlint-disable-next-line next/no-img-element */}
                <img src={`./${selected.preview}`} alt={`Rendered example of ${selected.title}`} />
                <div className="dialog-facts">
                  <div><span>Proof object</span><strong>{selected.proofObject}</strong></div>
                  <div><span>Watch for</span><strong>{selected.caveat}</strong></div>
                </div>
              </div>
              <div className="snippet-panel">
                <div className="snippet-header">
                  <span>Quarto source</span>
                  <Button size="sm" variant="outline" onClick={copySnippet}>{copied ? <Check aria-hidden="true" /> : <Copy aria-hidden="true" />}{copied ? "Copied" : "Copy"}</Button>
                </div>
                <pre><code>{selected.snippet}</code></pre>
                <span className="copy-status" aria-live="polite">{copied ? "Pattern source copied to the clipboard." : ""}</span>
              </div>
            </div>
          </DialogContent>
        ) : null}
      </Dialog>
    </main>
  );
}
