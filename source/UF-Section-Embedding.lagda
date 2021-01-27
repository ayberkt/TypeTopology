Martin Escardo, Jan 27 2021.

We write down in Agda a result attributed to Martin Escardo by Shulman
(2015) https://arxiv.org/abs/1507.03634

\begin{code}

{-# OPTIONS --without-K --exact-split --safe #-}

module UF-Section-Embedding where

open import SpartanMLTT

open import UF-Base
open import UF-FunExt
open import UF-Subsingletons renaming (⊤Ω to ⊤ ; ⊥Ω to ⊥)
open import UF-Subsingletons-FunExt
open import UF-Equiv
open import UF-Equiv-FunExt
open import UF-Retracts
open import UF-Embeddings
open import UF-EquivalenceExamples
open import UF-ExcludedMiddle
open import UF-Univalence
open import UF-UA-FunExt
open import UF-UniverseEmbedding
open import UF-PropIndexedPiSigma
open import UF-PropTrunc
open import UF-KrausLemma

splits : {X : 𝓤 ̇ } → (X → X) → (𝓥 : Universe) → 𝓤 ⊔ (𝓥 ⁺) ̇
splits {𝓤} {X} f 𝓥 = Σ A ꞉ 𝓥 ̇ , Σ r ꞉ (X → A) , Σ s ꞉ (A → X) , (r ∘ s ∼ id) × (f ∼ s ∘ r)

splits-gives-idempotent : {X : 𝓤 ̇ } (f : X → X)
                        → splits f 𝓥
                        → idempotent-map f
splits-gives-idempotent f (A , r , s , η , h) x =
  f (f x)         ≡⟨ ap f (h x) ⟩
  f (s (r x))     ≡⟨ h (s (r x)) ⟩
  s (r (s (r x))) ≡⟨ ap s (η (r x)) ⟩
  s (r x)         ≡⟨ (h x)⁻¹ ⟩
  f x ∎

split-via-embedding-gives-collapsible : {X : 𝓤 ̇ } (f : X → X)
                                      → ((A , r , s , η , h) : splits f 𝓥)
                                      → is-embedding s
                                      → (x : X) → collapsible (f x ≡ x)
split-via-embedding-gives-collapsible {𝓤} {𝓥} {X} f (A , r , s , η , h) e x = γ
 where
  ϕ : (x : X) → f x ≡ x → fiber s x
  ϕ x p = r x , (s (r x)         ≡⟨ ap (s ∘ r) (p ⁻¹) ⟩
                 s (r (f x))     ≡⟨ ap (s ∘ r) (h x) ⟩
                 s (r (s (r x))) ≡⟨ ap s (η (r x)) ⟩
                 s (r x)         ≡⟨ (h x)⁻¹ ⟩
                 f x             ≡⟨ p ⟩
                 x               ∎)

  ψ : (x : X) → fiber s x → f x ≡ x
  ψ x (a , q) = f x         ≡⟨ h x ⟩
                s (r x)     ≡⟨ ap (s ∘ r) (q ⁻¹) ⟩
                s (r (s a)) ≡⟨ ap s (η a) ⟩
                s a         ≡⟨ q ⟩
                x           ∎

  κ : f x ≡ x → f x ≡ x
  κ = ψ x ∘ ϕ x

  κ-constant : (p p' : f x ≡ x) → κ p ≡ κ p'
  κ-constant p p' = ap (ψ x) (e x (ϕ x p) (ϕ x p'))

  γ : collapsible (f x ≡ x)
  γ = κ , κ-constant

section-embedding-gives-collapsible : {X : 𝓤 ̇ } {A : 𝓥 ̇ }
                                      (r : X → A) (s : A → X) (η : r ∘ s ∼ id)
                                    → is-embedding s
                                    → (x : X) → collapsible (s (r x) ≡ x)
section-embedding-gives-collapsible {𝓤} {𝓥} {X} {A} r s η =
 split-via-embedding-gives-collapsible (s ∘ r) (A , r , s , η , (λ _ → refl))

collapsible-gives-split-via-embedding : {X : 𝓤 ̇ } (f : X → X)
                                      → idempotent-map f
                                      → ((x : X) → collapsible (f x ≡ x))
                                      → Σ (A , r , s , η , h) ꞉ splits f 𝓤 , is-embedding s
collapsible-gives-split-via-embedding {𝓤} {X} f i c = γ
 where
  κ : (x : X) → f x ≡ x → f x ≡ x
  κ x = pr₁ (c x)

  κ-constant : (x : X) → wconstant (κ x)
  κ-constant x = pr₂ (c x)

  P : X → 𝓤 ̇
  P x = fix (κ x)

  P-is-prop-valued : (x : X) → is-prop (P x)
  P-is-prop-valued x = Kraus-Lemma (κ x) (κ-constant x)

  A : 𝓤 ̇
  A = Σ x ꞉ X , P x

  s : A → X
  s (x , _) = x

  r : X → A
  r x = f x , to-fix (κ (f x)) (κ-constant (f x)) (i x)

  η : r ∘ s ∼ id
  η (x , p , _) = to-subtype-≡ P-is-prop-valued p

  h : f ∼ s ∘ r
  h x = refl

  α : (x : X) → fiber s x → P x
  α x ((x' , u , v) , p) = transport P p (u , v)

  β : (x : X) → P x → fiber s x
  β x (u , v) = (x , u , v) , refl

  βα : (x : X) → β x ∘ α x ∼ id
  βα x ((.x , u , v) , refl) = refl

  e : is-embedding s
  e x = retract-of-prop (β x , α x , βα x) (P-is-prop-valued x)

  γ : Σ (A , r , s , η , h) ꞉ splits f 𝓤 , is-embedding s
  γ = (A , r , s , η , h) , e

\end{code}

If we assume the existence of propositional truncations, we can
reformulate the above as follows:

\begin{code}

module _ (pe : propositional-truncations-exist) where

 open PropositionalTruncation pe

 split-via-embedding-gives-split-support : {X : 𝓤 ̇ } (f : X → X)
                                        → ((A , r , s , η , h) : splits f 𝓥)
                                        → is-embedding s
                                        → (x : X) → ∥ f x ≡ x ∥ → f x ≡ x
 split-via-embedding-gives-split-support f σ e x =
   collapsible-gives-split-support pe (split-via-embedding-gives-collapsible f σ e x)


 split-support-gives-split-via-embedding : {X : 𝓤 ̇ } (f : X → X)
                                      → idempotent-map f
                                      → ((x : X) → ∥ f x ≡ x ∥ → f x ≡ x)
                                      → Σ (A , r , s , η , h) ꞉ splits f 𝓤 , is-embedding s
 split-support-gives-split-via-embedding f i g =
   collapsible-gives-split-via-embedding f i (λ x → split-support-gives-collapsible pe (g x))

 section-embedding-gives-split-support : {X : 𝓤 ̇ } {A : 𝓥 ̇ }
                                       (r : X → A) (s : A → X) (η : r ∘ s ∼ id)
                                     → is-embedding s
                                     → (x : X) → ∥ s (r x) ≡ x ∥ → s (r x) ≡ x
 section-embedding-gives-split-support r s η e x =
   collapsible-gives-split-support pe (section-embedding-gives-collapsible r s η e x)

\end{code}
