Martin Escardo, 15 August 2014, with additions 23 January 2021.

Higgs' Involution Theorem. In any topos, if f : Ω → Ω is a
monomorphism, then it is an involution.

We adapt and prove the result in univalent mathematics, using
propositional and functional extensionality. (We don't rely on
propositional resizing (or impredicativity).)

There is a proof by diagram chasing with iterated pullbacks, in page
65 of Johnstone's Sketches of an Elephant, volume 1.

The proof given here is based on an exercise in page 160 of Lambek and
Scott's Introduction to Higher-Order Categorical Logic, attributed to
Scedrov. Thanks to Phil Scott for bringing my attention to this proof
during a visit to Birmingham.

\begin{code}

{-# OPTIONS --without-K --exact-split --safe #-}

open import SpartanMLTT
open import UF-Base
open import UF-Subsingletons renaming (Ω to Ω' ; ⊤Ω to ⊤ ; ⊥Ω to ⊥)
open import UF-FunExt
open import UF-Subsingletons-FunExt

module HiggsInvolutionTheorem
        {𝓤 : Universe}
        (fe : Fun-Ext)
        (pe : propext 𝓤)
       where

\end{code}

We work with Ω of universe 𝓤:

\begin{code}

Ω = Ω' 𝓤

\end{code}

Recall that a map f is left-cancellable if f p ≡ f q → p ≡ q, and
involutive if f (f p) ≡ p.

\begin{code}

higgs : (f : Ω → Ω) → left-cancellable f → involutive f
higgs f lc = VIII
  where
   I : (p : Ω) → f p ≡ ⊤ → p ≡ ⊤ → f ⊤ ≡ ⊤
   I p r s = transport (λ - → f - ≡ ⊤) s r

   II : (p : Ω) → f p ≡ ⊤ → f ⊤ ≡ ⊤ → p ≡ ⊤
   II p r s = lc (f p ≡⟨ r ⟩
                  ⊤   ≡⟨ s ⁻¹ ⟩
                  f ⊤ ∎)

   III : (p : Ω) → f p ≡ ⊤ → p ≡ f ⊤
   III p r = Ω-ext' pe fe (I p r) (II p r)

   IV : (p : Ω) → f (f p) ≡ ⊤ → p ≡ ⊤
   IV p r = lc (III (f p) r)

   V : (p : Ω) → f (f (f p)) ≡ ⊤ → f p ≡ ⊤
   V p = IV (f p)

   VI : (p : Ω) → f p ≡ ⊤ → f (f (f p)) ≡ ⊤
   VI p r = iv ∙ r
    where
     i : f (f p) ≡ f ⊤
     i = ap f r

     ii : f ⊤ ≡ p
     ii = (III p r)⁻¹

     iii : f (f p) ≡ p
     iii = i ∙ ii

     iv : f (f (f p)) ≡ f p
     iv = ap f iii

   VII : (p : Ω) → f (f (f p)) ≡ f p
   VII p = Ω-ext' pe fe (V p) (VI p)

   VIII : (p : Ω) → f (f p) ≡ p
   VIII p = lc (VII p)

\end{code}

Added 23 Jan 2021. From a group structure on Ω we get excluded middle,
as an application of Higgs Theorem. I am not sure whether this is
already known in the literature or the folkore. I certainly haven't
seen it in print or the folkore. I've written a blog post about
this here:

https://homotopytypetheory.org/2021/01/23/can-the-type-of-truth-values-be-given-the-structure-of-a-group/

Such a group structure is necessarily abelian.

Moreover, any left-cancellable monoid structure (_⊕_ , O) on Ω is an
abelian group structure with p ⊕ p = O for all p : Ω, that is, such
that every element is its own inverse.

To define negation on Ω we need function extensionality, which we are
assuming in this module:

\begin{code}

⇁_ : Ω → Ω
⇁_ = not fe

⇁⇁_ : Ω → Ω
⇁⇁ p = ⇁(⇁ p)

open import UF-ExcludedMiddle

lc-monoid-structure-on-Ω-gives-EM :

    (O : Ω)
    (_⊕_ : Ω → Ω → Ω)
  → left-neutral O _⊕_
  → right-neutral O _⊕_
  → associative _⊕_
  → ((p : Ω) → left-cancellable (p ⊕_))
  → excluded-middle 𝓤

lc-monoid-structure-on-Ω-gives-EM O _⊕_ ln rn assoc lc = γ
 where
  invol : (p : Ω) → involutive (p ⊕_)
  invol p = higgs (p ⊕_) (lc p)

  own-inv : (p : Ω) → p ⊕ p ≡ O
  own-inv p = p ⊕ p       ≡⟨ (rn _)⁻¹ ⟩
              (p ⊕ p) ⊕ O ≡⟨ assoc _ _ _ ⟩
              p ⊕ (p ⊕ O) ≡⟨ invol p O ⟩
              O           ∎

  to-≡ : (p q : Ω) → p ⊕ q ≡ O → p ≡ q
  to-≡ p q e = p           ≡⟨ (rn _)⁻¹ ⟩
               p ⊕ O       ≡⟨ ap (p ⊕_) (e ⁻¹) ⟩
               p ⊕ (p ⊕ q) ≡⟨ (assoc _ _ _)⁻¹ ⟩
               (p ⊕ p) ⊕ q ≡⟨ ap (_⊕ q) (own-inv p) ⟩
               O ⊕ q       ≡⟨ ln _ ⟩
               q           ∎

  f : Ω → Ω
  f p = p ⊕ (⊥ ⊕ ⊤)

  f-invol : involutive f
  f-invol p = f (f p)                 ≡⟨ refl ⟩
              (p ⊕ (⊥ ⊕ ⊤)) ⊕ (⊥ ⊕ ⊤) ≡⟨ assoc p (⊥ ⊕ ⊤) (⊥ ⊕ ⊤) ⟩
              p ⊕ ((⊥ ⊕ ⊤) ⊕ (⊥ ⊕ ⊤)) ≡⟨ ap (p ⊕_) (own-inv (⊥ ⊕ ⊤)) ⟩
              p ⊕ O                   ≡⟨ rn p ⟩
              p                       ∎

  α : (p : Ω) → f p ≡ ⊤ → p ≡ ⊥
  α p e = to-≡ p ⊥ e'
   where
    e' = p ⊕ ⊥             ≡⟨ (rn _)⁻¹ ⟩
         (p ⊕ ⊥) ⊕ O       ≡⟨ ap ((p ⊕ ⊥) ⊕_) ((own-inv ⊤)⁻¹) ⟩
         (p ⊕ ⊥) ⊕ (⊤ ⊕ ⊤) ≡⟨ (assoc (p ⊕ ⊥) ⊤ ⊤)⁻¹ ⟩
         ((p ⊕ ⊥) ⊕ ⊤) ⊕ ⊤ ≡⟨ ap (_⊕ ⊤) (assoc p ⊥ ⊤) ⟩
         (p ⊕ (⊥ ⊕ ⊤)) ⊕ ⊤ ≡⟨ refl ⟩
         f p ⊕ ⊤           ≡⟨ ap (_⊕ ⊤) e ⟩
         ⊤ ⊕ ⊤             ≡⟨ own-inv ⊤ ⟩
         O                 ∎

  β : (p : Ω) → p ≡ ⊥ → f p ≡ ⊤
  β p e = f p         ≡⟨ refl ⟩
          p ⊕ (⊥ ⊕ ⊤) ≡⟨ (assoc p ⊥ ⊤)⁻¹ ⟩
          (p ⊕ ⊥) ⊕ ⊤ ≡⟨ ap (λ - → (- ⊕ ⊥) ⊕ ⊤) e ⟩
          (⊥ ⊕ ⊥) ⊕ ⊤ ≡⟨ ap (_⊕ ⊤) (own-inv ⊥) ⟩
          O ⊕ ⊤       ≡⟨ ln ⊤ ⟩
          ⊤           ∎

  alternative-definition : (p : Ω) → f p ≡ ⇁ p
  alternative-definition p = Ω-ext' pe fe a b
   where
    a : f p ≡ ⊤ → (⇁ p) ≡ ⊤
    a e = equal-⊥-gives-not-equal-⊤ fe pe p (α p e)

    b : (⇁ p) ≡ ⊤ → f p ≡ ⊤
    b e = β p (not-equal-⊤-gives-equal-⊥ fe pe p e)

  ν : (p : Ω) → (⇁⇁ p) ≡ p
  ν p = ⇁⇁ p      ≡⟨ ap ⇁_ ((alternative-definition p)⁻¹) ⟩
        (⇁ (f p)) ≡⟨ (alternative-definition (f p))⁻¹ ⟩
        f (f p)   ≡⟨ f-invol p ⟩
        p         ∎

  δ : (P : 𝓤 ̇ ) → is-prop P → ¬¬ P → P
  δ P i = Idtofun (ap _holds (ν (P , i)))

  γ : excluded-middle 𝓤
  γ = DNE-gives-EM fe δ

\end{code}

Additional facts that are not needed to conclude exxcluded middle:

\begin{code}

  from-≡ : (p q : Ω) → p ≡ q → p ⊕ q ≡ O
  from-≡ p q e = p ⊕ q ≡⟨ ap (_⊕ q) e ⟩
                 q ⊕ q ≡⟨ own-inv q ⟩
                 O     ∎

  abelian : (p q : Ω) → p ⊕ q ≡ q ⊕ p
  abelian p q = to-≡ _ _
                  ((p ⊕ q) ⊕ (q ⊕ p) ≡⟨ assoc _ _ _ ⟩
                   p ⊕ (q ⊕ (q ⊕ p)) ≡⟨ ap (p ⊕_) ((assoc _ _ _)⁻¹) ⟩
                   p ⊕ ((q ⊕ q) ⊕ p) ≡⟨ ap (λ - → p ⊕ (- ⊕ p)) (own-inv q) ⟩
                   p ⊕ (O ⊕ p)       ≡⟨ ap (p ⊕_) (ln p) ⟩
                   p ⊕ p             ≡⟨ own-inv p ⟩
                   O                 ∎)

\end{code}

This shows that any cancellative monoid structure on Ω is
automatically an abelian group structure.
