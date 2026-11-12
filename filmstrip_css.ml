(** Stylesheet for {!Filmstrip}. Consumers inline this in their page head
    (server-side) or serve it as a static file; there is no JS here.

    Guarantees encoded below: horizontal scroll at phone width, tap targets of
    at least 44px, and no page-level horizontal overflow (the track scrolls, the
    document never does). *)

let stylesheet =
  {css|.filmstrip {
  max-width: 100%;
  overflow: hidden;
}
.filmstrip-track {
  display: flex;
  flex-direction: row;
  gap: 0.5rem;
  margin: 0;
  padding: 0.25rem;
  list-style: none;
  overflow-x: auto;
  overflow-y: hidden;
  -webkit-overflow-scrolling: touch;
  scrollbar-width: thin;
}
.filmstrip-tile {
  flex: 0 0 auto;
}
.filmstrip-link {
  display: flex;
  flex-direction: column;
  align-items: flex-start;
  justify-content: flex-start;
  box-sizing: border-box;
  min-width: 44px;
  min-height: 44px;
  padding: 0.5rem 0.75rem;
  text-decoration: none;
  color: inherit;
  border: 1px solid currentColor;
  border-radius: 0.5rem;
}
.filmstrip-glyph {
  font-size: 1.5rem;
  line-height: 1.5rem;
}
.filmstrip-name {
  font-weight: 600;
}
.filmstrip-summary {
  font-size: 0.875rem;
  white-space: normal;
  max-width: 14rem;
}
.filmstrip-count {
  font-variant-numeric: tabular-nums;
}
.filmstrip-count::after {
  content: " " attr(data-stamp-label);
  font-size: 0.75rem;
  opacity: 0.75;
}
@media (max-width: 480px) {
  .filmstrip-link {
    min-width: 44px;
    min-height: 44px;
  }
}
|css}
