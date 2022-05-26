module Comparse.Parser.Typeclass

open Comparse.Bytes.Typeclass
open Comparse.Parser

class parseable_serializeable (bytes:Type0) {|bytes_like bytes|} (a:Type) = {
  [@@@FStar.Tactics.Typeclasses.no_method] base: parser_serializer_exact bytes a;
}

val parse: #bytes:Type0 -> {|bytes_like bytes|} -> a:Type -> {|parseable_serializeable bytes a|} -> bytes -> option a
let parse #bytes #bl a #ps buf =
  ps.base.parse_exact buf

val serialize: #bytes:Type0 -> {|bytes_like bytes|} -> a:Type -> {|parseable_serializeable bytes a|} -> a -> bytes
let serialize #bytes #bl a #ps x =
  ps.base.serialize_exact x

val parse_serialize_inv_lemma: #bytes:Type0 -> {|bytes_like bytes|} -> a:Type -> {|parseable_serializeable bytes a|} -> x:a -> Lemma (
    // #bytes implicit argument needed to know to which bytes we are serializing to
    parse a (serialize #bytes a x) == Some x
  )
let parse_serialize_inv_lemma #bytes #bl a #ps x =
  ps.base.parse_serialize_inv_exact x

val serialize_parse_inv_lemma: #bytes:Type0 -> {|bytes_like bytes|} -> a:Type -> {|parseable_serializeable bytes a|} -> buf:bytes -> Lemma (
    match parse a buf with
    | Some x -> serialize a x == buf
    | None -> True
  )
let serialize_parse_inv_lemma #bytes #bl a #ps buf =
  ps.base.serialize_parse_inv_exact buf

val is_valid: #bytes:Type0 -> {|bytes_like bytes|} -> a:Type -> {|parseable_serializeable bytes a|} -> bytes_compatible_pre bytes -> a -> Type0
let is_valid #bytes #bl a #ps pre x =
  ps.base.is_valid_exact pre x

val parse_pre_lemma: #bytes:Type0 -> {|bytes_like bytes|} -> a:Type -> {|parseable_serializeable bytes a|} ->pre:bytes_compatible_pre bytes -> buf:bytes -> Lemma
  (requires pre buf)
  (ensures (
    match parse a buf with
    | Some x -> is_valid a pre x
    | None -> True
  ))
let parse_pre_lemma #bytes #bl a #ps pre buf =
  ps.base.parse_pre_exact pre buf

val serialize_pre_lemma: #bytes:Type0 -> {|bytes_like bytes|} -> a:Type -> {|parseable_serializeable bytes a|} ->pre:bytes_compatible_pre bytes -> x:a -> Lemma
  (requires is_valid a pre x)
  (ensures pre (serialize a x))
let serialize_pre_lemma #bytes #bl a #ps pre x =
  ps.base.serialize_pre_exact pre x

val mk_parseable_serializeable_from_exact:
  #bytes:Type0 -> {|bytes_like bytes|} -> #a:Type ->
  pse_a:parser_serializer_exact bytes a -> parseable_serializeable bytes a
let mk_parseable_serializeable_from_exact #bytes #bl #a pse_a = {
  base = pse_a;
}

val mk_parseable_serializeable:
  #bytes:Type0 -> {|bytes_like bytes|} -> #a:Type ->
  ps_a:parser_serializer bytes a -> parseable_serializeable bytes a
let mk_parseable_serializeable #bytes #bl #a ps_a =
  mk_parseable_serializeable_from_exact (ps_to_pse ps_a)